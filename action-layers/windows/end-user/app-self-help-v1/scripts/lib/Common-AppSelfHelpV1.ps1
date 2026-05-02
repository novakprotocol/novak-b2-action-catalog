$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

function Write-AppSelfHelpEvidence {
    param([string]$ActionId,[string]$Result,[string]$Message,[object]$Data)
    $Documents = [Environment]::GetFolderPath("MyDocuments")
    if ([string]::IsNullOrWhiteSpace($Documents)) { $Documents = $env:TEMP }
    $Root = Join-Path $Documents "NOVAK-B2-Windows-SelfCheck"
    $SafeAction = $ActionId -replace "[^A-Za-z0-9_-]", "_"
    $Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $EvidenceDir = Join-Path $Root "$Stamp-$SafeAction"
    New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null
    $Record = [ordered]@{
        schema_version = "1.0"
        action_id = $ActionId
        result = $Result
        message = $Message
        timestamp_utc = (Get-Date).ToUniversalTime().ToString("o")
        safety = [ordered]@{ no_admin = $true; no_credential = $true; no_target_list = $true; local_user_safe = $true; mutation_approved = $false }
        data = $Data
    }
    $JsonPath = Join-Path $EvidenceDir "result.json"
    $TextPath = Join-Path $EvidenceDir "result.txt"
    $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($JsonPath, ($Record | ConvertTo-Json -Depth 20), $Utf8NoBom)
    $TextLines = @("ACTION_ID=$ActionId","RESULT=$Result","MESSAGE=$Message","EVIDENCE_JSON=$JsonPath","EVIDENCE_TEXT=$TextPath")
    [System.IO.File]::WriteAllLines($TextPath, $TextLines, $Utf8NoBom)
    foreach ($Line in $TextLines) { Write-Host $Line }
}

function Get-SafeRegistryPresence {
    param([string]$Path)
    try { return (Test-Path -Path $Path) } catch { return $false }
}

function Invoke-AppSelfHelpAction {
    param(
        [string]$ActionId,[string]$Name,[string]$Description,[string]$Kind,
        [string]$IssueArea,[string]$ActionType,[string]$Risk,
        [string[]]$Targets = @(),[int]$Hours = 24
    )
    $Result = "PASS"
    $Message = "Completed safe app self-help action."
    $Data = [ordered]@{ name=$Name; description=$Description; kind=$Kind; issue_area=$IssueArea; action_type=$ActionType; risk=$Risk; target_count=@($Targets).Count }
    try {
        switch ($Kind) {
            "ProcessCount" {
                $Rows=@()
                foreach ($Target in $Targets) { $Rows += [pscustomobject]@{ target=$Target; count=@(Get-Process -Name $Target -ErrorAction SilentlyContinue).Count } }
                $Data["process_counts"]=$Rows
                $Message="Collected process count summary without reading app content."
            }
            "ServiceStatus" {
                $Rows=@()
                foreach ($Target in $Targets) {
                    $Svc=Get-Service -Name $Target -ErrorAction SilentlyContinue
                    if ($null -eq $Svc) { $Rows += [pscustomobject]@{ service=$Target; present=$false; status="" } }
                    else { $Rows += [pscustomobject]@{ service=$Target; present=$true; status=[string]$Svc.Status } }
                }
                $Data["service_status"]=$Rows
                $Message="Collected service status without changing services."
            }
            "CommandPresence" {
                $Rows=@()
                foreach ($Target in $Targets) { $Rows += [pscustomobject]@{ command=$Target; present=($null -ne (Get-Command $Target -ErrorAction SilentlyContinue)) } }
                $Data["command_presence"]=$Rows
                $Message="Checked command availability without launching commands."
            }
            "EnvironmentPresence" {
                $Rows=@()
                foreach ($Target in $Targets) {
                    $Value=[Environment]::GetEnvironmentVariable($Target,"User")
                    if ($null -eq $Value) { $Value=[Environment]::GetEnvironmentVariable($Target,"Process") }
                    $Rows += [pscustomobject]@{ variable=$Target; present=(-not [string]::IsNullOrWhiteSpace($Value)) }
                }
                $Data["environment_presence"]=$Rows
                $Message="Checked environment variable presence without recording values."
            }
            "FolderPresence" {
                $Rows=@()
                foreach ($Target in $Targets) { $Rows += [pscustomobject]@{ token_marker =$Target; present=(Test-Path -LiteralPath ([Environment]::ExpandEnvironmentVariables($Target))) } }
                $Data["folder_presence"]=$Rows
                $Message="Checked folder presence without listing contents."
            }
            "FileAssociationPresence" {
                $Rows=@()
                foreach ($Target in $Targets) {
                    $UserChoice="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Target\UserChoice"
                    $ClassRoot="Registry::HKEY_CLASSES_ROOT\$Target"
                    $Rows += [pscustomobject]@{ extension=$Target; user_choice_present=(Get-SafeRegistryPresence -Path $UserChoice); class_root_present=(Get-SafeRegistryPresence -Path $ClassRoot) }
                }
                $Data["file_association_presence"]=$Rows
                $Message="Checked file association presence without recording handler values."
            }
            "RegistryPresence" {
                $Rows=@()
                foreach ($Target in $Targets) { $Rows += [pscustomobject]@{ registry_path_label=($Target -replace "^HKCU:\\","HKCU:\"); present=(Get-SafeRegistryPresence -Path $Target) } }
                $Data["registry_presence"]=$Rows
                $Message="Checked registry presence without recording values."
            }
            "AppxPackageCount" {
                $Rows=@()
                foreach ($Target in $Targets) { $Rows += [pscustomobject]@{ package_pattern=$Target; count=@(Get-AppxPackage -Name $Target -ErrorAction SilentlyContinue).Count } }
                $Data["appx_package_counts"]=$Rows
                $Message="Counted user-visible Appx packages without reading account data."
            }
            "EventCount" {
                $Rows=@()
                $StartTime=(Get-Date).AddHours(-1 * [Math]::Abs($Hours))
                foreach ($Target in $Targets) {
                    try { $Events=@(Get-WinEvent -FilterHashtable @{ LogName=$Target; StartTime=$StartTime; Level=@(2,3) } -ErrorAction Stop); $Rows += [pscustomobject]@{ log_name=$Target; hours=[Math]::Abs($Hours); warning_error_count=$Events.Count; available=$true } }
                    catch { $Rows += [pscustomobject]@{ log_name=$Target; hours=[Math]::Abs($Hours); warning_error_count=-1; available=$false } }
                }
                $Data["event_counts"]=$Rows
                $Message="Collected event counts only; raw event output was not collected."
            }
            "SettingsOpen" {
                if (@($Targets).Count -lt 1) { throw "SettingsOpen requires one URI target." }
                Start-Process $Targets[0]
                $Data["opened_uri"]=$Targets[0]
                $Message="Opened a user-controlled Windows settings surface."
            }
            "SupportEvidenceSummary" {
                $Documents=[Environment]::GetFolderPath("MyDocuments")
                if ([string]::IsNullOrWhiteSpace($Documents)) { $Documents=$env:TEMP }
                $Root=Join-Path $Documents "NOVAK-B2-Windows-SelfCheck"
                $Exists=Test-Path -LiteralPath $Root
                $DirCount=0
                if ($Exists) { $DirCount=@(Get-ChildItem -LiteralPath $Root -Directory -ErrorAction SilentlyContinue).Count }
                $Data["evidence_root_exists"]=$Exists
                $Data["evidence_directory_count"]=$DirCount
                $Message="Collected local evidence root summary without listing evidence names."
            }
            "PlanOnly" {
                $Data["plan_only"]=$true
                $Data["guidance"]=$Targets
                $Message="Recorded plan-only guidance. No system change was made."
            }
            default { throw "Unsupported kind: $Kind" }
        }
    } catch {
        $Result="WARN"
        $Message="Completed with handled warning."
        $Data["error_type"]=$_.Exception.GetType().FullName
        $Data["error_message"]=$_.Exception.Message
    }
    Write-AppSelfHelpEvidence -ActionId $ActionId -Result $Result -Message $Message -Data $Data
}

