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
        evidence_policy = "local_user_profile_only_no_credentials_no_mutation_no_runtime_target_input"
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

function ConvertTo-ItopsBool {
    param([object]$Value)
    if ($null -eq $Value) { return $false }
    return [bool]$Value
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

function Invoke-ItopsNoInputAction {
    param(
        [Parameter(Mandatory=$true)]$Context,
        [Parameter(Mandatory=$true)][hashtable]$Action
    )

    try {
        $type = [string]$Action.Type
        $data = @{}
        $result = "PASS"
        $message = "Completed read-only no-input check."
        $exit = 0

        switch ($type) {
            "ServiceStatus" {
                $services = @(Get-ItopsServiceSummary -Names @([string]$Action.ServiceName))
                $expected = if ($Action.ContainsKey("ExpectedStatus")) { [string]$Action.ExpectedStatus } else { "" }
                if ($expected -and ($services[0].status -ne $expected)) {
                    $result = "WARN"
                    $exit = 2
                    $message = "Service status does not match expected status."
                } else {
                    $message = "Collected service status."
                }
                $data = @{ service = $services[0] }
            }

            "ProcessCount" {
                $names = @($Action.ProcessNames)
                $items = @()
                foreach ($n in $names) {
                    $procs = @(Get-Process -Name $n -ErrorAction SilentlyContinue)
                    $items += @{ process_name=$n; count=$procs.Count; running=($procs.Count -gt 0) }
                }
                $data = @{ processes=$items }
                $message = "Collected process presence/count summary."
            }

            "CommandAvailable" {
                $cmd = [string]$Action.CommandName
                $found = Get-Command $cmd -ErrorAction SilentlyContinue
                $data = @{ command=$cmd; available=($null -ne $found); source_redacted=$true }
                $message = "Checked command availability."
                if ($Action.ContainsKey("WarnIfMissing") -and [bool]$Action.WarnIfMissing -and $null -eq $found) {
                    $result = "WARN"; $exit = 2; $message = "Command is not available on this machine."
                }
            }

            "RegistryValuePresent" {
                $path = [string]$Action.RegistryPath
                $name = [string]$Action.ValueName
                $present = $false
                $pathPresent = Test-Path -LiteralPath $path -ErrorAction SilentlyContinue
                if ($pathPresent) {
                    try {
                        $p = Get-ItemProperty -LiteralPath $path -Name $name -ErrorAction Stop
                        $present = $null -ne $p.$name
                    } catch { $present = $false }
                }
                $data = @{ registry_path_present=$pathPresent; value_name=$name; value_present=$present; value_redacted=$true }
                $message = "Checked registry value presence without recording value."
            }

            "EventCount" {
                $hours = [int]$Action.HoursBack
                if ($hours -le 0) { $hours = 24 }
                $providers = @($Action.ProviderPatterns)
                $log = [string]$Action.LogName
                $count = Get-ItopsEventCount -LogName $log -StartTime (Get-Date).AddHours(-1 * $hours) -ProviderNameLike $providers -Levels @(1,2,3)
                $data = @{ log=$log; hours_back=$hours; event_count=$count; providers=$providers; event_details_redacted=$true }
                $message = "Collected recent event warning/error count."
            }

            "CimCount" {
                $class = [string]$Action.ClassName
                $namespace = if ($Action.ContainsKey("Namespace")) { [string]$Action.Namespace } else { "root\cimv2" }
                $count = $null
                try { $count = @(Get-CimInstance -Namespace $namespace -ClassName $class -ErrorAction Stop).Count } catch {}
                $data = @{ namespace=$namespace; class_name=$class; instance_count=$count; details_redacted=$true }
                $message = "Collected CIM instance count."
            }

            "CimPropertySummary" {
                $class = [string]$Action.ClassName
                $props = @($Action.Properties)
                $first = $null
                try { $first = Get-CimInstance -ClassName $class -ErrorAction Stop | Select-Object -First 1 } catch {}
                $items = @()
                foreach ($p in $props) {
                    $present = $false
                    $valueType = "not_available"
                    if ($null -ne $first) {
                        $prop = $first.PSObject.Properties[$p]
                        if ($null -ne $prop) {
                            $present = $true
                            if ($null -ne $prop.Value) { $valueType = $prop.Value.GetType().Name } else { $valueType = "null" }
                        }
                    }
                    $items += @{ property=$p; present=$present; value_type=$valueType; value_redacted=$true }
                }
                $data = @{ class_name=$class; properties=$items }
                $message = "Collected CIM property presence summary without values."
            }

            "KnownFolderSummary" {
                $folderKind = [string]$Action.FolderKind
                $path = ""
                switch ($folderKind) {
                    "Desktop" { $path = [Environment]::GetFolderPath("Desktop") }
                    "Documents" { $path = [Environment]::GetFolderPath("MyDocuments") }
                    "Favorites" { $path = [Environment]::GetFolderPath("Favorites") }
                    "Templates" { $path = [Environment]::GetFolderPath("Templates") }
                    "Downloads" { $path = Join-Path $env:USERPROFILE "Downloads" }
                    "Pictures" { $path = [Environment]::GetFolderPath("MyPictures") }
                    "Music" { $path = [Environment]::GetFolderPath("MyMusic") }
                    "Videos" { $path = [Environment]::GetFolderPath("MyVideos") }
                    default { $path = "" }
                }
                $exists = (-not [string]::IsNullOrWhiteSpace($path)) -and (Test-Path -LiteralPath $path -PathType Container -ErrorAction SilentlyContinue)
                $canList = $false
                if ($exists) { try { Get-ChildItem -LiteralPath $path -ErrorAction Stop | Select-Object -First 1 | Out-Null; $canList = $true } catch {} }
                $data = @{ folder_kind=$folderKind; path_present=(-not [string]::IsNullOrWhiteSpace($path)); exists=$exists; can_list=$canList; path_redacted=$true }
                $message = "Checked known folder presence/listability without recording path."
                if (-not $exists) { $result = "WARN"; $exit = 2 }
            }

            "DriveSummary" {
                $driveType = if ($Action.ContainsKey("DriveType")) { [int]$Action.DriveType } else { 0 }
                $filter = if ($driveType -gt 0) { "DriveType=$driveType" } else { $null }
                $drives = if ($filter) { @(Get-CimInstance Win32_LogicalDisk -Filter $filter) } else { @(Get-CimInstance Win32_LogicalDisk) }
                $items = @()
                foreach ($d in $drives) {
                    $freePct = if ($d.Size -and $d.Size -gt 0) { [math]::Round(($d.FreeSpace / $d.Size) * 100, 2) } else { $null }
                    $items += @{ drive=$d.DeviceID; drive_type=[int]$d.DriveType; size_gb=if($d.Size){[math]::Round($d.Size/1GB,2)}else{$null}; free_percent=$freePct }
                }
                $data = @{ drive_count=$items.Count; drives=$items }
                $message = "Collected drive summary."
            }

            "NetworkAdapterSummary" {
                $adapters = @(Get-NetAdapter -ErrorAction SilentlyContinue)
                $data = @{
                    adapter_count = $adapters.Count
                    up_count = @($adapters | Where-Object { $_.Status -eq "Up" }).Count
                    disconnected_count = @($adapters | Where-Object { $_.Status -eq "Disconnected" }).Count
                    disabled_count = @($adapters | Where-Object { $_.Status -eq "Disabled" }).Count
                }
                $message = "Collected network adapter status counts."
            }

            "NetworkProfileSummary" {
                $profiles = @(Get-NetConnectionProfile -ErrorAction SilentlyContinue)
                $counts = @{}
                foreach ($p in $profiles) {
                    $cat = [string]$p.NetworkCategory
                    if (-not $counts.ContainsKey($cat)) { $counts[$cat] = 0 }
                    $counts[$cat]++
                }
                $data = @{ profile_count=$profiles.Count; category_counts=$counts; names_redacted=$true }
                $message = "Collected network profile category counts."
            }

            "DnsConfigSummary" {
                $servers = @(Get-DnsClientServerAddress -ErrorAction SilentlyContinue | Where-Object { $_.AddressFamily -eq 2 })
                $suffixes = @(Get-DnsClient -ErrorAction SilentlyContinue | Where-Object { -not [string]::IsNullOrWhiteSpace($_.ConnectionSpecificSuffix) })
                $data = @{ ipv4_dns_server_interface_count=$servers.Count; suffix_present_interface_count=$suffixes.Count; server_values_redacted=$true; suffix_values_redacted=$true }
                $message = "Collected DNS configuration counts with values redacted."
            }

            "SmbSummary" {
                $mappings = @()
                $connections = @()
                try { $mappings = @(Get-SmbMapping -ErrorAction Stop) } catch {}
                try { $connections = @(Get-SmbConnection -ErrorAction Stop) } catch {}
                $data = @{ smb_mapping_count=$mappings.Count; smb_connection_count=$connections.Count; paths_redacted=$true; server_names_redacted=$true }
                $message = "Collected SMB mapping/connection counts with names and paths redacted."
            }

            "FirewallSummary" {
                $profiles = @(Get-NetFirewallProfile -ErrorAction SilentlyContinue)
                $data = @{
                    profile_count=$profiles.Count
                    enabled_count=@($profiles | Where-Object { $_.Enabled }).Count
                    disabled_count=@($profiles | Where-Object { -not $_.Enabled }).Count
                }
                $message = "Collected firewall profile enabled counts."
            }

            "PowerPlanSummary" {
                $active = $null
                try {
                    $out = powercfg /getactivescheme 2>$null | Out-String
                    if ($out -match "GUID") { $active = "present" }
                } catch {}
                $data = @{ active_power_scheme_present=($active -eq "present"); scheme_value_redacted=$true }
                $message = "Collected active power plan presence."
            }

            "EnvVarPresence" {
                $names = @($Action.EnvNames)
                $items = @()
                foreach ($n in $names) {
                    $v = [Environment]::GetEnvironmentVariable($n)
                    $items += @{ name=$n; value_present=(-not [string]::IsNullOrWhiteSpace($v)); value_redacted=$true }
                }
                $data = @{ variables=$items }
                $message = "Collected environment variable presence without values."
            }

            "EvidenceRootSummary" {
                $root = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "NOenterpriseK-B2-Windows-SelfCheck"
                $exists = Test-Path -LiteralPath $root -PathType Container
                $dirCount = 0; $fileCount = 0; $sizeBytes = 0
                if ($exists) {
                    $dirCount = @(Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue).Count
                    $files = @(Get-ChildItem -LiteralPath $root -File -Recurse -ErrorAction SilentlyContinue)
                    $fileCount = $files.Count
                    foreach ($f in $files) { $sizeBytes += $f.Length }
                }
                $data = @{ evidence_root_exists=$exists; run_folder_count=$dirCount; file_count=$fileCount; size_mb=[math]::Round($sizeBytes/1MB,2); path_redacted=$true }
                $message = "Collected NOenterpriseK B2 self-check evidence root summary."
            }

            default {
                $result = "WARN"; $exit = 2
                $message = "Unknown no-input check type."
                $data = @{ type=$type }
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
