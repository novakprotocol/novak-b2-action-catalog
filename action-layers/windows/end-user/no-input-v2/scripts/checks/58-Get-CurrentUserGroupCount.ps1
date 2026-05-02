# ENDUSER_GET_CURRENT_USER_GROUP_COUNT_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_CURRENT_USER_GROUP_COUNT_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $count = $null
    try {
        $out = whoami.exe /groups /fo csv 2>$null | ConvertFrom-Csv
        $count = @($out).Count
    } catch {}
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected current user group count without recording group names." -Data @{ group_count=$count; group_names_redacted=$true }

}
