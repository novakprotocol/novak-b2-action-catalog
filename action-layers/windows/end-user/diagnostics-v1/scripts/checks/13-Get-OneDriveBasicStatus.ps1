# ENDUSER_GET_ONEDRIVE_BASIC_STATUS_V1
# NOenterpriseK B2 Windows End User Easy Button Script
# Safe boundary: read-only, current-user context, no credentials, no mutation, no target inventory in code.

[CmdletBinding()]
param(
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SafeEvidence.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_ONEDRIVE_BASIC_STATUS_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $processes = @(Get-Process OneDrive -ErrorAction SilentlyContinue)
    $knownPaths = @()
    foreach ($name in "OneDrive","OneDriveCommercial","OneDriveConsumer") {
        $v = [Environment]::GetEnvironmentVariable($name)
        if (-not [string]::IsNullOrWhiteSpace($v)) { $knownPaths += $v }
    }
    $data = @{
        onedrive_process_running = $processes.Count -gt 0
        onedrive_process_count = $processes.Count
        known_onedrive_folder_count = $knownPaths.Count
        known_onedrive_folders_exist = @($knownPaths | ForEach-Object { @{ path=$_; exists=(Test-Path -LiteralPath $_ -ErrorAction SilentlyContinue) } })
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected basic OneDrive status." -Data $data

}
