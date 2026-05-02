Set-StrictMode -Version 2.0

function New-ItopsEvidenceContext {
    param(
        [string]$ActionId,
        [string]$EvidenceRoot
    )

    if ([string]::IsNullOrWhiteSpace($EvidenceRoot)) {
        $EvidenceRoot = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "NOenterpriseK-B2-Windows-SelfCheck"
    }

    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $safeAction = ($ActionId -replace '[^A-Za-z0-9_.-]', '_')
    $runDir = Join-Path $EvidenceRoot "$stamp-$safeAction"
    New-Item -ItemType Directory -Path $runDir -Force | Out-Null

    [pscustomobject]@{
        ActionId = $ActionId
        StartedAt = (Get-Date).ToString("o")
        EvidenceRoot = $EvidenceRoot
        RunDir = $runDir
        JsonPath = Join-Path $runDir "result.json"
        TextPath = Join-Path $runDir "result.txt"
    }
}

function Write-ItopsResult {
    param(
        [Parameter(Mandatory=$true)]$Context,
        [Parameter(Mandatory=$true)][string]$Result,
        [string]$Message = "",
        [hashtable]$Data = @{},
        [int]$ExitCode = 0
    )

    $payload = [ordered]@{
        action_id = $Context.ActionId
        result = $Result
        message = $Message
        started_at = $Context.StartedAt
        completed_at = (Get-Date).ToString("o")
        computer_name = $env:COMPUTERNAME
        user_context = "$env:USERDOMAIN\$env:USERNAME"
        evidence_policy = "local_user_profile_only_no_admin_no_credentials_no_mutation_no_runtime_target_input"
        data = $Data
    }

    $payload | ConvertTo-Json -Depth 12 | Set-Content -Path $Context.JsonPath -Encoding UTF8

    @(
        "ACTION_ID=$($Context.ActionId)"
        "RESULT=$Result"
        "MESSAGE=$Message"
        "COMPUTER=$env:COMPUTERNAME"
        "USER_CONTEXT=$env:USERDOMAIN\$env:USERNAME"
        "JSON=$($Context.JsonPath)"
        "COMPLETED_AT=$((Get-Date).ToString("o"))"
    ) | Set-Content -Path $Context.TextPath -Encoding UTF8

    Write-Host "ACTION_ID=$($Context.ActionId)"
    Write-Host "RESULT=$Result"
    if ($Message) { Write-Host "MESSAGE=$Message" }
    Write-Host "EVIDENCE_JSON=$($Context.JsonPath)"
    Write-Host "EVIDENCE_TEXT=$($Context.TextPath)"
    exit $ExitCode
}

function Get-ItopsEventCount {
    param(
        [string]$LogName,
        [datetime]$StartTime,
        [string[]]$ProviderNameLike = @(),
        [int[]]$Levels = @(1,2,3)
    )
    try {
        $events = @(Get-WinEvent -FilterHashtable @{ LogName = $LogName; StartTime = $StartTime } -ErrorAction Stop |
            Where-Object {
                $okLevel = $Levels -contains [int]$_.Level
                if ($ProviderNameLike.Count -eq 0) { return $okLevel }
                $prov = [string]$_.ProviderName
                foreach ($p in $ProviderNameLike) {
                    if ($prov -match $p) { return $okLevel }
                }
                return $false
            })
        return $events.Count
    } catch {
        return $null
    }
}

function Get-ItopsServiceSummary {
    param([string[]]$Names)
    $out = @()
    foreach ($n in $Names) {
        $svc = Get-Service -Name $n -ErrorAction SilentlyContinue
        if ($svc) {
            $out += [pscustomobject]@{
                name = $n
                present = $true
                status = [string]$svc.Status
                start_type = try { [string]$svc.StartType } catch { "unknown" }
            }
        } else {
            $out += [pscustomobject]@{
                name = $n
                present = $false
                status = "not_present"
                start_type = "not_present"
            }
        }
    }
    return $out
}

function Invoke-ItopsNoAdminAction {
    param(
        [Parameter(Mandatory=$true)]$Context,
        [Parameter(Mandatory=$true)][hashtable]$Action
    )

    try {
        $type = [string]$Action.Type
        $result = "PASS"
        $message = "Completed read-only no-admin check."
        $exit = 0
        $data = @{}

        switch ($type) {
            "PrinterSummary" {
                $printers = @()
                try { $printers = @(Get-CimInstance Win32_Printer -ErrorAction Stop) } catch {}
                $defaultCount = @($printers | Where-Object { $_.Default }).Count
                $networkCount = @($printers | Where-Object { $_.Network }).Count
                $localCount = @($printers | Where-Object { -not $_.Network }).Count
                $offlineCount = @($printers | Where-Object { $_.WorkOffline }).Count
                $data = @{ printer_count=$printers.Count; default_printer_count=$defaultCount; network_printer_count=$networkCount; local_printer_count=$localCount; offline_count=$offlineCount; names_redacted=$true }
                $message = "Collected printer summary with printer names redacted."
            }
            "PrintJobSummary" {
                $jobs = @()
                try { $jobs = @(Get-CimInstance Win32_PrintJob -ErrorAction Stop) } catch {}
                $data = @{ print_job_count=$jobs.Count; job_names_redacted=$true; printer_names_redacted=$true }
                $message = "Collected print job count with names redacted."
            }
            "DefaultPrinterPresent" {
                $printers = @()
                try { $printers = @(Get-CimInstance Win32_Printer -ErrorAction Stop) } catch {}
                $defaultCount = @($printers | Where-Object { $_.Default }).Count
                if ($defaultCount -eq 0) { $result="WARN"; $exit=2; $message="No default printer observed." } else { $message="Default printer present." }
                $data = @{ default_printer_count=$defaultCount; printer_names_redacted=$true }
            }
            "ServiceStatus" {
                $svc = @(Get-ItopsServiceSummary -Names @([string]$Action.ServiceName))
                $expected = if ($Action.ContainsKey("ExpectedStatus")) { [string]$Action.ExpectedStatus } else { "" }
                if ($expected -and $svc[0].status -ne $expected) { $result="WARN"; $exit=2; $message="Service status does not match expected status." } else { $message="Collected service status." }
                $data = @{ service=$svc[0] }
            }
            "ProcessCount" {
                $names = @($Action.ProcessNames)
                $items = @()
                foreach ($n in $names) {
                    $p = @(Get-Process -Name $n -ErrorAction SilentlyContinue)
                    $items += @{ process_name=$n; count=$p.Count; running=($p.Count -gt 0) }
                }
                $data = @{ processes=$items }
                $message = "Collected process count summary."
            }
            "CommandAvailable" {
                $cmd = [string]$Action.CommandName
                $found = Get-Command $cmd -ErrorAction SilentlyContinue
                $data = @{ command=$cmd; available=($null -ne $found); source_redacted=$true }
                $message = "Checked command availability."
                if ($Action.ContainsKey("WarnIfMissing") -and [bool]$Action.WarnIfMissing -and $null -eq $found) {
                    $result="WARN"; $exit=2; $message="Command not available."
                }
            }
            "KnownFolderTopLevelSummary" {
                $kind = [string]$Action.FolderKind
                $path = ""
                switch ($kind) {
                    "Desktop" { $path = [Environment]::GetFolderPath("Desktop") }
                    "Documents" { $path = [Environment]::GetFolderPath("MyDocuments") }
                    "Downloads" { $path = Join-Path $env:USERPROFILE "Downloads" }
                    "Pictures" { $path = [Environment]::GetFolderPath("MyPictures") }
                    "Videos" { $path = [Environment]::GetFolderPath("MyVideos") }
                    "Music" { $path = [Environment]::GetFolderPath("MyMusic") }
                    "Favorites" { $path = [Environment]::GetFolderPath("Favorites") }
                    default { $path = "" }
                }
                $exists = (-not [string]::IsNullOrWhiteSpace($path)) -and (Test-Path -LiteralPath $path -PathType Container -ErrorAction SilentlyContinue)
                $fileCount = $null; $folderCount = $null
                if ($exists) {
                    try {
                        $children = @(Get-ChildItem -LiteralPath $path -Force -ErrorAction Stop)
                        $fileCount = @($children | Where-Object { -not $_.PSIsContainer }).Count
                        $folderCount = @($children | Where-Object { $_.PSIsContainer }).Count
                    } catch {
                        $result="WARN"; $exit=2; $message="Folder exists but could not be listed."
                    }
                } else {
                    $result="WARN"; $exit=2; $message="Known folder not present or not visible."
                }
                if ($message -eq "Completed read-only no-admin check.") { $message = "Collected known folder top-level summary without names or paths." }
                $data = @{ folder_kind=$kind; exists=$exists; top_level_file_count=$fileCount; top_level_folder_count=$folderCount; names_redacted=$true; path_redacted=$true }
            }
            "FileExtensionSummary" {
                $kind = [string]$Action.FolderKind
                $path = if ($kind -eq "Documents") { [Environment]::GetFolderPath("MyDocuments") } elseif ($kind -eq "Desktop") { [Environment]::GetFolderPath("Desktop") } elseif ($kind -eq "Downloads") { Join-Path $env:USERPROFILE "Downloads" } else { "" }
                $counts = @{}
                if (-not [string]::IsNullOrWhiteSpace($path) -and (Test-Path -LiteralPath $path -PathType Container -ErrorAction SilentlyContinue)) {
                    $files = @(Get-ChildItem -LiteralPath $path -File -ErrorAction SilentlyContinue)
                    foreach ($f in $files) {
                        $ext = if ([string]::IsNullOrWhiteSpace($f.Extension)) { "(none)" } else { $f.Extension.ToLowerInvariant() }
                        if (-not $counts.ContainsKey($ext)) { $counts[$ext] = 0 }
                        $counts[$ext]++
                    }
                } else {
                    $result="WARN"; $exit=2; $message="Folder not present or not visible."
                }
                if ($message -eq "Completed read-only no-admin check.") { $message = "Collected file extension count summary without names or paths." }
                $data = @{ folder_kind=$kind; extension_counts=$counts; names_redacted=$true; path_redacted=$true }
            }
            "RegistryPresence" {
                $path = [string]$Action.RegistryPath
                $name = [string]$Action.ValueName
                $pathPresent = Test-Path -LiteralPath $path -ErrorAction SilentlyContinue
                $valuePresent = $false
                if ($pathPresent) {
                    try {
                        $p = Get-ItemProperty -LiteralPath $path -Name $name -ErrorAction Stop
                        $valuePresent = $null -ne $p.$name
                    } catch {}
                }
                $data = @{ registry_path_present=$pathPresent; value_name=$name; value_present=$valuePresent; value_redacted=$true }
                $message = "Checked registry value presence without recording value."
            }
            "EventCount" {
                $hours = [int]$Action.HoursBack
                if ($hours -le 0) { $hours = 24 }
                $providers = @($Action.ProviderPatterns)
                $log = [string]$Action.LogName
                $count = Get-ItopsEventCount -LogName $log -StartTime (Get-Date).AddHours(-1*$hours) -ProviderNameLike $providers -Levels @(1,2,3)
                $data = @{ log=$log; hours_back=$hours; event_count=$count; providers=$providers; event_details_redacted=$true }
                $message = "Collected event warning/error count."
            }
            "CimCount" {
                $class = [string]$Action.ClassName
                $namespace = if ($Action.ContainsKey("Namespace")) { [string]$Action.Namespace } else { "root\cimv2" }
                $count = $null
                try { $count = @(Get-CimInstance -Namespace $namespace -ClassName $class -ErrorAction Stop).Count } catch {}
                $data = @{ namespace=$namespace; class_name=$class; instance_count=$count; details_redacted=$true }
                $message = "Collected CIM instance count."
            }
            "PnpClassSummary" {
                $class = [string]$Action.PnpClass
                $devices = @()
                try { $devices = @(Get-PnpDevice -Class $class -ErrorAction Stop) } catch {}
                $statusCounts = @{}
                foreach ($d in $devices) {
                    $s = [string]$d.Status
                    if (-not $statusCounts.ContainsKey($s)) { $statusCounts[$s] = 0 }
                    $statusCounts[$s]++
                }
                $data = @{ pnp_class=$class; device_count=$devices.Count; status_counts=$statusCounts; device_names_redacted=$true }
                $message = "Collected PnP class status count summary."
            }
            "CurrentUserCertStoreCount" {
                $store = [string]$Action.Store
                $count = $null
                try { $count = @(Get-ChildItem -Path "Cert:\CurrentUser\$store" -ErrorAction Stop).Count } catch {}
                $data = @{ current_user_cert_store=$store; certificate_count=$count; certificate_names_redacted=$true }
                $message = "Collected CurrentUser certificate store count."
            }
            "NetworkCounts" {
                $adapters = @(Get-NetAdapter -ErrorAction SilentlyContinue)
                $vpnish = @($adapters | Where-Object { "$($_.InterfaceDescription) $($_.Name)" -match "vpn|tap|tun|pulse|anyconnect|globalprotect|zscaler|wireguard|ppp|ras" }).Count
                $wifi = @($adapters | Where-Object { "$($_.InterfaceDescription) $($_.Name)" -match "wi-fi|wireless|wlan|802\.11" }).Count
                $eth = @($adapters | Where-Object { "$($_.InterfaceDescription) $($_.Name)" -match "ethernet|gigabit|realtek|intel" }).Count
                $data = @{ adapter_count=$adapters.Count; up_count=@($adapters | Where-Object Status -eq "Up").Count; vpnish_count=$vpnish; wifiish_count=$wifi; ethernetish_count=$eth; adapter_names_redacted=$true }
                $message = "Collected network adapter category counts."
            }
            "TcpConnectionStateCounts" {
                $conns = @()
                try { $conns = @(Get-NetTCPConnection -ErrorAction Stop) } catch {}
                $counts = @{}
                foreach ($c in $conns) {
                    $s = [string]$c.State
                    if (-not $counts.ContainsKey($s)) { $counts[$s] = 0 }
                    $counts[$s]++
                }
                $data = @{ tcp_connection_count=$conns.Count; state_counts=$counts; endpoints_redacted=$true }
                $message = "Collected TCP connection state counts without endpoints."
            }
            "UdpEndpointCount" {
                $eps = @()
                try { $eps = @(Get-NetUDPEndpoint -ErrorAction Stop) } catch {}
                $data = @{ udp_endpoint_count=$eps.Count; endpoints_redacted=$true }
                $message = "Collected UDP endpoint count without endpoint values."
            }
            "ScheduledTaskCount" {
                $tasks = @()
                try { $tasks = @(Get-ScheduledTask -ErrorAction Stop) } catch {}
                $states = @{}
                foreach ($t in $tasks) {
                    $s = [string]$t.State
                    if (-not $states.ContainsKey($s)) { $states[$s] = 0 }
                    $states[$s]++
                }
                $data = @{ scheduled_task_count=$tasks.Count; state_counts=$states; task_names_redacted=$true }
                $message = "Collected scheduled task state counts without names."
            }
            "StartupApprovedCount" {
                $paths = @(
                    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run",
                    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
                )
                $count = 0
                foreach ($p in $paths) {
                    if (Test-Path $p) {
                        try { $count += ((Get-ItemProperty -Path $p).PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" }).Count } catch {}
                    }
                }
                $data = @{ startup_approved_entry_count=$count; entry_names_redacted=$true }
                $message = "Collected startup approved entry count."
            }
            "AppxPackageCount" {
                $packages = @()
                try { $packages = @(Get-AppxPackage -ErrorAction Stop) } catch {}
                $data = @{ current_user_appx_package_count=$packages.Count; package_names_redacted=$true }
                $message = "Collected current-user AppX package count."
            }
            "PowerShellModuleCount" {
                $mods = @()
                try { $mods = @(Get-Module -ListAvailable -ErrorAction Stop) } catch {}
                $data = @{ module_count=$mods.Count; module_names_redacted=$true }
                $message = "Collected available PowerShell module count."
            }
            "TempFolderSummary" {
                $p = [System.IO.Path]::GetTempPath()
                $exists = Test-Path -LiteralPath $p -PathType Container -ErrorAction SilentlyContinue
                $fileCount=$null; $folderCount=$null
                if ($exists) {
                    try {
                        $children = @(Get-ChildItem -LiteralPath $p -ErrorAction Stop)
                        $fileCount = @($children | Where-Object { -not $_.PSIsContainer }).Count
                        $folderCount = @($children | Where-Object { $_.PSIsContainer }).Count
                    } catch { $result="WARN"; $exit=2; $message="Temp path exists but could not be listed." }
                }
                if ($message -eq "Completed read-only no-admin check.") { $message="Collected user temp folder summary without names." }
                $data = @{ temp_path_exists=$exists; file_count=$fileCount; folder_count=$folderCount; names_redacted=$true; path_redacted=$true }
            }
            "DiskFreeThreshold" {
                $threshold = [int]$Action.ThresholdPercent
                $disks = @(Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3")
                $low = 0; $items = @()
                foreach ($d in $disks) {
                    $freePct = if ($d.Size -and $d.Size -gt 0) { [math]::Round(($d.FreeSpace / $d.Size) * 100, 2) } else { $null }
                    $below = ($null -ne $freePct -and $freePct -lt $threshold)
                    if ($below) { $low++ }
                    $items += @{ drive=$d.DeviceID; free_percent=$freePct; below_threshold=$below }
                }
                if ($low -gt 0) { $result="WARN"; $exit=2; $message="One or more fixed disks below free-space threshold." } else { $message="No fixed disks below free-space threshold." }
                $data = @{ threshold_percent=$threshold; low_disk_count=$low; disks=$items }
            }
            default {
                $result="WARN"; $exit=2
                $message="Unknown action type."
                $data=@{ type=$type }
            }
        }

        Write-ItopsResult -Context $Context -Result $result -Message $message -Data $data -ExitCode $exit
    }
    catch {
        Write-ItopsResult -Context $Context -Result "WARN" -Message $_.Exception.Message -Data @{
            error_type = $_.Exception.GetType().FullName
            note = "WARN means the local machine blocked or did not support this read-only query."
            check_type = if ($Action.ContainsKey("Type")) { [string]$Action.Type } else { "unknown" }
        } -ExitCode 2
    }
}
