# ENDUSER_GET_RECENT_GROUP_POLICY_ERROR_COUNT_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_RECENT_GROUP_POLICY_ERROR_COUNT_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $start = (Get-Date).AddHours(-24)
    $countSystem = Get-ItopsEventCount -LogName "System" -StartTime $start -ProviderNameLike @("GroupPolicy") -Levels @(1,2,3)
    $countApp = Get-ItopsEventCount -LogName "Application" -StartTime $start -ProviderNameLike @("GroupPolicy") -Levels @(1,2,3)
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected recent Group Policy warning/error counts." -Data @{ hours_back=24; system_event_count=$countSystem; application_event_count=$countApp; event_details_redacted=$true }

}
