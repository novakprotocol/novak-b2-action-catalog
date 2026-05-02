# ENDUSER_GET_STORAGE_ENVIRONMENT_enterpriseRIABLE_SUMMARY_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_STORAGE_ENVIRONMENT_enterpriseRIABLE_SUMMARY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $names = @("HOMEDRIVE","HOMEPATH","HOMESHARE","OneDrive","OneDriveCommercial","OneDriveConsumer","USERPROFILE")
    $items = @()
    foreach ($n in $names) {
        $v = [Environment]::GetEnvironmentVariable($n)
        $items += @{ name=$n; value_present=(-not [string]::IsNullOrWhiteSpace($v)); value_redacted=$true }
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected storage-related environment variable presence summary without values." -Data @{ variables=$items }

}
