# ENDUSER_CHECK_DNS_CLIENT_SERVICE_STATUS_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_CHECK_DNS_CLIENT_SERVICE_STATUS_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $services = Get-ItopsServiceSummary -Names @("Dnscache")
    $running = $services[0].present -and $services[0].status -eq "Running"
    Write-ItopsResult -Context $ctx -Result $(if ($running) {"PASS"} else {"WARN"}) -Message "Collected DNS Client service status." -Data @{ services=$services } -ExitCode $(if ($running) {0} else {2})

}
