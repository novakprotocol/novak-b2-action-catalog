# ENDUSER_GET_RECENT_NETWORK_ERROR_COUNT_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_RECENT_NETWORK_ERROR_COUNT_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $start = (Get-Date).AddHours(-24)
    $count = Get-ItopsEventCount -LogName "System" -StartTime $start -ProviderNameLike @("Tcpip","DNS","Netlogon","NlaSvc","Dhcp","e1","Netwtw","WLAN") -Levels @(1,2,3)
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected recent network-related warning/error count." -Data @{ hours_back=24; event_count=$count; event_details_redacted=$true }

}
