Set-StrictMode -Version 2.0

function New-ItopsEvidenceContext {
    param([string]$ActionId, [string]$EvidenceRoot)

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
        evidence_policy = "current_user_self_fix_candidate_no_admin_no_credentials_no_target_inventory_apply_required_for_changes"
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

function Get-ItopsKnownPath {
    param([string]$Kind)

    switch ($Kind) {
        "UserTemp" { return [System.IO.Path]::GetTempPath() }
        "InternetCache" { return [Environment]::GetFolderPath("InternetCache") }
        "Recent" { return [Environment]::GetFolderPath("Recent") }
        "Desktop" { return [Environment]::GetFolderPath("Desktop") }
        "Documents" { return [Environment]::GetFolderPath("MyDocuments") }
        "Downloads" { return (Join-Path $env:USERPROFILE "Downloads") }
        "TeamsClassicCache" { return (Join-Path $env:APPDATA "Microsoft\Teams") }
        "TeamsNewCache" { return (Join-Path $env:LOCALAPPDATA "Packages\MSTeams_8wekyb3d8bbwe") }
        "EdgeCache" { return (Join-Path $env:LOCALAPPDATA "Microsoft\Edge\User Data\Default\Cache") }
        "ChromeCache" { return (Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data\Default\Cache") }
        "OfficeFileCache" { return (Join-Path $env:LOCALAPPDATA "Microsoft\Office\16.0\OfficeFileCache") }
        "OneDriveLogs" { return (Join-Path $env:LOCALAPPDATA "Microsoft\OneDrive\logs") }
        "ExplorerThumbCache" { return (Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Explorer") }
        "CrashDumps" { return (Join-Path $env:LOCALAPPDATA "CrashDumps") }
        "WERArchive" { return (Join-Path $env:LOCALAPPDATA "Microsoft\Windows\WER\ReportArchive") }
        "WERQueue" { return (Join-Path $env:LOCALAPPDATA "Microsoft\Windows\WER\ReportQueue") }
        "TempInternetFiles" { return (Join-Path $env:LOCALAPPDATA "Microsoft\Windows\INetCache") }
        default { return "" }
    }
}

function Get-ItopsFolderStats {
    param([string]$Path, [int]$OlderThanDays = 0)
    $exists = (-not [string]::IsNullOrWhiteSpace($Path)) -and (Test-Path -LiteralPath $Path -PathType Container -ErrorAction SilentlyContinue)
    $files = @()
    if ($exists) {
        try {
            $files = @(Get-ChildItem -LiteralPath $Path -File -Recurse -Force -ErrorAction SilentlyContinue)
            if ($OlderThanDays -gt 0) {
                $cutoff = (Get-Date).AddDays(-1 * $OlderThanDays)
                $files = @($files | Where-Object { $_.LastWriteTime -lt $cutoff })
            }
        } catch {
            $files = @()
        }
    }
    $bytes = 0
    foreach ($f in $files) { try { $bytes += [int64]$f.Length } catch {} }
    return @{
        exists = [bool]$exists
        file_count = $files.Count
        size_mb = [math]::Round($bytes / 1MB, 2)
        names_redacted = $true
        path_redacted = $true
    }
}

function Remove-ItopsFolderFilesSafe {
    param([string]$Path, [int]$OlderThanDays = 0)
    if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path -PathType Container -ErrorAction SilentlyContinue)) {
        return @{ removed_count=0; failed_count=0 }
    }
    $files = @(Get-ChildItem -LiteralPath $Path -File -Recurse -Force -ErrorAction SilentlyContinue)
    if ($OlderThanDays -gt 0) {
        $cutoff = (Get-Date).AddDays(-1 * $OlderThanDays)
        $files = @($files | Where-Object { $_.LastWriteTime -lt $cutoff })
    }
    $removed = 0
    $failed = 0
    foreach ($f in $files) {
        try {
            Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop
            $removed++
        } catch {
            $failed++
        }
    }
    return @{ removed_count=$removed; failed_count=$failed }
}

function Invoke-ItopsSelfFixAction {
    param(
        [Parameter(Mandatory=$true)]$Context,
        [Parameter(Mandatory=$true)][hashtable]$Action,
        [bool]$Apply = $false
    )

    try {
        $type = [string]$Action.Type
        $data = @{ apply = [bool]$Apply }
        $result = if ($Apply) { "PASS" } else { "PLAN" }
        $message = if ($Apply) { "Self-fix candidate completed." } else { "Dry-run plan only. Re-run with -Apply to make the user-scope change." }
        $exit = 0

        switch ($type) {
            "Command" {
                $exe = [string]$Action.Command
                $args = @($Action.Arguments)
                $data.command = $exe
                $data.arguments_redacted = $false
                $data.arguments = $args
                if ($Apply) {
                    $p = Start-Process -FilePath $exe -ArgumentList $args -Wait -PassThru -WindowStyle Hidden -ErrorAction Stop
                    $data.process_exit_code = $p.ExitCode
                    if ($p.ExitCode -ne 0) { $result="WARN"; $exit=2; $message="Command ran but returned non-zero exit code." }
                }
            }
            "RestartExplorer" {
                $data.warning = "May close/reopen File Explorer windows."
                if ($Apply) {
                    Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                    Start-Process explorer.exe
                }
            }
            "RestartProcess" {
                $names = @($Action.ProcessNames)
                $start = if ($Action.ContainsKey("StartCommand")) { [string]$Action.StartCommand } else { "" }
                $stopped = 0
                foreach ($n in $names) {
                    $procs = @(Get-Process -Name $n -ErrorAction SilentlyContinue)
                    if ($Apply) {
                        foreach ($p in $procs) { try { $p.CloseMainWindow() | Out-Null; Start-Sleep -Milliseconds 300; if (-not $p.HasExited) { $p.Kill() }; $stopped++ } catch {} }
                    }
                }
                if ($Apply -and -not [string]::IsNullOrWhiteSpace($start)) {
                    try { Start-Process $start -ErrorAction SilentlyContinue } catch {}
                }
                $data.process_names = $names
                $data.processes_found = $true
                $data.stopped_count = $stopped
                $data.start_command_present = -not [string]::IsNullOrWhiteSpace($start)
                $data.note = "May close user apps. Use only when the user is ready."
            }
            "StartProcess" {
                $cmd = [string]$Action.Command
                $data.command = $cmd
                if ($Apply) { Start-Process $cmd -ErrorAction Stop }
            }
            "ClearKnownFolder" {
                $kind = [string]$Action.FolderKind
                $days = if ($Action.ContainsKey("OlderThanDays")) { [int]$Action.OlderThanDays } else { 0 }
                $path = Get-ItopsKnownPath -Kind $kind
                $statsBefore = Get-ItopsFolderStats -Path $path -OlderThanDays $days
                $data.folder_kind = $kind
                $data.older_than_days = $days
                $data.before = $statsBefore
                if ($Apply) {
                    $remove = Remove-ItopsFolderFilesSafe -Path $path -OlderThanDays $days
                    $data.removal = $remove
                    $data.after = Get-ItopsFolderStats -Path $path -OlderThanDays $days
                    if ($remove.failed_count -gt 0) { $result="WARN"; $exit=2; $message="Some files could not be removed." }
                }
            }
            "ClearRecycleBin" {
                $data.warning = "Empties the current user's visible Recycle Bin. This is destructive."
                if ($Apply) {
                    Clear-RecycleBin -Force -ErrorAction Stop
                }
            }
            "OpenKnownFolder" {
                $kind = [string]$Action.FolderKind
                $path = Get-ItopsKnownPath -Kind $kind
                $exists = (-not [string]::IsNullOrWhiteSpace($path)) -and (Test-Path -LiteralPath $path)
                $data.folder_kind = $kind
                $data.exists = $exists
                $data.path_redacted = $true
                if ($Apply -and $exists) { Start-Process explorer.exe -ArgumentList $path }
                if (-not $exists) { $result="WARN"; $exit=2; $message="Known folder does not exist or is not visible." }
            }
            "EnsureEvidenceRoot" {
                $root = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "NOenterpriseK-B2-Windows-SelfCheck"
                if ($Apply) { New-Item -ItemType Directory -Path $root -Force | Out-Null }
                $data.evidence_root_exists_before = Test-Path -LiteralPath $root -PathType Container
                $data.path_redacted = $true
            }
            "CreateSupportBundle" {
                $root = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "NOenterpriseK-B2-Windows-SelfCheck"
                $exists = Test-Path -LiteralPath $root -PathType Container
                $data.evidence_root_exists = $exists
                if ($Apply -and $exists) {
                    $zip = Join-Path ([Environment]::GetFolderPath("Desktop")) ("NOenterpriseK-B2-Windows-SelfCheck-Bundle-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".zip")
                    Compress-Archive -Path (Join-Path $root "*") -DestinationPath $zip -Force
                    $data.zip_created = $true
                    $data.zip_location = "Desktop"
                }
            }
            "OpenControlPanelApplet" {
                $cmd = [string]$Action.Command
                $data.command = $cmd
                if ($Apply) { Start-Process control.exe -ArgumentList $cmd }
            }
            default {
                $result = "WARN"; $exit=2; $message="Unknown self-fix type."
                $data.type = $type
            }
        }

        Write-ItopsResult -Context $Context -Result $result -Message $message -Data $data -ExitCode $exit
    }
    catch {
        Write-ItopsResult -Context $Context -Result "WARN" -Message $_.Exception.Message -Data @{
            error_type = $_.Exception.GetType().FullName
            note = "WARN means this self-fix candidate could not complete in the current user context."
            apply = [bool]$Apply
        } -ExitCode 2
    }
}

