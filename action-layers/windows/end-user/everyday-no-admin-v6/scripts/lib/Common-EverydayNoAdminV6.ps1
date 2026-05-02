Set-StrictMode -Version 2.0

function New-NovakEvidenceContext {
    param([string]$ActionId, [string]$EvidenceRoot)

    if ([string]::IsNullOrWhiteSpace($EvidenceRoot)) {
        $EvidenceRoot = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "NOVAK-B2-Windows-SelfCheck"
    }

    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $safeAction = ($ActionId -replace "[^A-Za-z0-9_.-]", "_")
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

function Write-NovakResult {
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

function Get-NovakFolderPath {
    param([string]$Kind)
    switch ($Kind) {
        "Desktop" { return [Environment]::GetFolderPath("Desktop") }
        "Documents" { return [Environment]::GetFolderPath("MyDocuments") }
        "Downloads" { return (Join-Path $env:USERPROFILE "Downloads") }
        "Pictures" { return [Environment]::GetFolderPath("MyPictures") }
        "Videos" { return [Environment]::GetFolderPath("MyVideos") }
        "Music" { return [Environment]::GetFolderPath("MyMusic") }
        "UserProfile" { return $env:USERPROFILE }
        "UserTemp" { return [System.IO.Path]::GetTempPath() }
        default { return "" }
    }
}

function Get-NovakEventCount {
    param([string]$LogName, [datetime]$StartTime, [string[]]$ProviderNameLike = @(), [int[]]$Levels = @(1,2,3))
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

function Invoke-NovakEverydayAction {
    param([Parameter(Mandatory=$true)]$Context, [Parameter(Mandatory=$true)][hashtable]$Action)

    try {
        $type = [string]$Action.Type
        $result = "PASS"
        $message = "Completed read-only no-admin check."
        $exit = 0
        $data = @{}

        switch ($type) {
            "PathHealth" {
                $path = Get-NovakFolderPath -Kind ([string]$Action.FolderKind)
                $exists = (-not [string]::IsNullOrWhiteSpace($path)) -and (Test-Path -LiteralPath $path -PathType Container -ErrorAction SilentlyContinue)
                $canList = $false
                if ($exists) {
                    try { Get-ChildItem -LiteralPath $path -Force -ErrorAction Stop | Select-Object -First 1 | Out-Null; $canList = $true } catch {}
                }
                if (-not $exists -or -not $canList) { $result="WARN"; $exit=2; $message="Path is missing or not listable." } else { $message="Path exists and is listable." }
                $data = @{ folder_kind=$Action.FolderKind; exists=$exists; can_list=$canList; path_redacted=$true }
            }
            "FolderAgeSummary" {
                $path = Get-NovakFolderPath -Kind ([string]$Action.FolderKind)
                $days = [int]$Action.OlderThanDays
                $exists = (-not [string]::IsNullOrWhiteSpace($path)) -and (Test-Path -LiteralPath $path -PathType Container -ErrorAction SilentlyContinue)
                $count = $null
                $sizeMb = $null
                if ($exists) {
                    $cutoff = (Get-Date).AddDays(-1 * $days)
                    $files = @(Get-ChildItem -LiteralPath $path -File -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cutoff })
                    $count = $files.Count
                    $bytes = 0
                    foreach ($f in $files) { try { $bytes += [int64]$f.Length } catch {} }
                    $sizeMb = [math]::Round($bytes / 1MB, 2)
                } else { $result="WARN"; $exit=2; $message="Folder not present or not visible." }
                if ($message -eq "Completed read-only no-admin check.") { $message="Collected old-file count and size summary without names or paths." }
                $data = @{ folder_kind=$Action.FolderKind; older_than_days=$days; exists=$exists; old_file_count=$count; old_file_size_mb=$sizeMb; names_redacted=$true; path_redacted=$true }
            }
            "ExtensionCount" {
                $path = Get-NovakFolderPath -Kind ([string]$Action.FolderKind)
                $extensions = @($Action.Extensions)
                $counts = @{}
                foreach ($e in $extensions) { $counts[[string]$e] = 0 }
                $exists = (-not [string]::IsNullOrWhiteSpace($path)) -and (Test-Path -LiteralPath $path -PathType Container -ErrorAction SilentlyContinue)
                if ($exists) {
                    $files = @(Get-ChildItem -LiteralPath $path -File -Recurse -Force -ErrorAction SilentlyContinue)
                    foreach ($f in $files) {
                        $ext = $f.Extension.ToLowerInvariant()
                        if ($counts.ContainsKey($ext)) { $counts[$ext]++ }
                    }
                } else { $result="WARN"; $exit=2; $message="Folder not present or not visible." }
                if ($message -eq "Completed read-only no-admin check.") { $message="Collected selected extension counts without names or paths." }
                $data = @{ folder_kind=$Action.FolderKind; extension_counts=$counts; names_redacted=$true; path_redacted=$true }
            }
            "EnvPresence" {
                $items = @()
                foreach ($n in @($Action.Names)) {
                    $v = [Environment]::GetEnvironmentVariable([string]$n)
                    $items += @{ name=[string]$n; value_present=(-not [string]::IsNullOrWhiteSpace($v)); value_redacted=$true }
                }
                $data = @{ variables=$items }
                $message = "Collected environment variable presence without values."
            }
            "CommandAvailable" {
                $cmd = [string]$Action.CommandName
                $found = Get-Command $cmd -ErrorAction SilentlyContinue
                $data = @{ command=$cmd; available=($null -ne $found); source_redacted=$true }
                $message = "Checked command availability."
                if ($Action.ContainsKey("WarnIfMissing") -and [bool]$Action.WarnIfMissing -and $null -eq $found) { $result="WARN"; $exit=2; $message="Command not available." }
            }
            "ProcessGroupCount" {
                $items = @()
                foreach ($n in @($Action.ProcessNames)) {
                    $p = @(Get-Process -Name ([string]$n) -ErrorAction SilentlyContinue)
                    $items += @{ process_name=[string]$n; count=$p.Count; running=($p.Count -gt 0) }
                }
                $data = @{ processes=$items }
                $message = "Collected process group count summary."
            }
            "ServiceGroupStatus" {
                $items = @()
                foreach ($n in @($Action.ServiceNames)) {
                    $svc = Get-Service -Name ([string]$n) -ErrorAction SilentlyContinue
                    if ($svc) { $items += @{ name=[string]$n; present=$true; status=[string]$svc.Status } }
                    else { $items += @{ name=[string]$n; present=$false; status="not_present" } }
                }
                $data = @{ services=$items }
                $message = "Collected service group status summary."
            }
            "EventCount" {
                $count = Get-NovakEventCount -LogName ([string]$Action.LogName) -StartTime (Get-Date).AddHours(-1 * [int]$Action.HoursBack) -ProviderNameLike @($Action.ProviderPatterns) -Levels @(1,2,3)
                $data = @{ log=$Action.LogName; hours_back=$Action.HoursBack; event_count=$count; providers=@($Action.ProviderPatterns); event_details_redacted=$true }
                $message = "Collected warning/error event count."
            }
            "RegistryPresence" {
                $path = [string]$Action.RegistryPath
                $name = [string]$Action.ValueName
                $pathPresent = Test-Path -LiteralPath $path -ErrorAction SilentlyContinue
                $valuePresent = $false
                if ($pathPresent) {
                    try { $p = Get-ItemProperty -LiteralPath $path -Name $name -ErrorAction Stop; $valuePresent = $null -ne $p.$name } catch {}
                }
                $data = @{ registry_path_present=$pathPresent; value_name=$name; value_present=$valuePresent; value_redacted=$true }
                $message = "Checked registry value presence without recording value."
            }
            "CimCount" {
                $count = $null
                try { $count = @(Get-CimInstance -ClassName ([string]$Action.ClassName) -ErrorAction Stop).Count } catch {}
                $data = @{ class_name=$Action.ClassName; instance_count=$count; details_redacted=$true }
                $message = "Collected CIM instance count."
            }
            "CertificateStoreCount" {
                $count = $null
                try { $count = @(Get-ChildItem -Path "Cert:\CurrentUser\$($Action.Store)" -ErrorAction Stop).Count } catch {}
                $data = @{ current_user_cert_store=$Action.Store; certificate_count=$count; certificate_names_redacted=$true }
                $message = "Collected current-user certificate store count."
            }
            "NetworkStateCount" {
                $conns = @()
                try { $conns = @(Get-NetTCPConnection -ErrorAction Stop) } catch {}
                $counts = @{}
                foreach ($c in $conns) { $s = [string]$c.State; if (-not $counts.ContainsKey($s)) { $counts[$s] = 0 }; $counts[$s]++ }
                $data = @{ tcp_connection_count=$conns.Count; state_counts=$counts; endpoints_redacted=$true }
                $message = "Collected network state counts without endpoints."
            }
            "ScheduledTaskSummary" {
                $tasks = @()
                try { $tasks = @(Get-ScheduledTask -ErrorAction Stop) } catch {}
                $states = @{}
                foreach ($t in $tasks) { $s = [string]$t.State; if (-not $states.ContainsKey($s)) { $states[$s] = 0 }; $states[$s]++ }
                $data = @{ scheduled_task_count=$tasks.Count; state_counts=$states; names_redacted=$true }
                $message = "Collected scheduled task counts without names."
            }
            default {
                $result = "WARN"; $exit = 2
                $message = "Unknown action type."
                $data = @{ type=$type }
            }
        }

        Write-NovakResult -Context $Context -Result $result -Message $message -Data $data -ExitCode $exit
    } catch {
        Write-NovakResult -Context $Context -Result "WARN" -Message $_.Exception.Message -Data @{ error_type=$_.Exception.GetType().FullName; note="Read-only query blocked or unsupported." } -ExitCode 2
    }
}
