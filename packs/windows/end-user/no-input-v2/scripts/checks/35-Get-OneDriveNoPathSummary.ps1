# ENDUSER_GET_ONEDRIVE_NO_PATH_SUMMARY_V1
# NOenterpriseK B2 Windows End User No-Input Script
# Safe boundary: read-only, current-user context, no credentials, no mutation, no target input, no IP list.

[CmdletBinding()]
param(
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SafeEvidence.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_ONEDRIVE_NO_PATH_SUMMARY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $processes = @(Get-Process OneDrive -ErrorAction SilentlyContinue)
    $envNames = @("OneDrive","OneDriveCommercial","OneDriveConsumer")
    $folderCount = 0
    foreach ($n in $envNames) {
        $v = [Environment]::GetEnvironmentVariable($n)
        if (-not [string]::IsNullOrWhiteSpace($v) -and (Test-Path -LiteralPath $v -ErrorAction SilentlyContinue)) { $folderCount++ }
    }
    $data = @{
        process_running = $processes.Count -gt 0
        process_count = $processes.Count
        known_folder_count = $folderCount
        paths_redacted = $true
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected OneDrive no-path summary." -Data $data

}
