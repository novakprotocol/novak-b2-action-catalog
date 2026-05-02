# ENDUSER_CHECK_TIME_SERVICE_STATUS_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_CHECK_TIME_SERVICE_STATUS_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $services = Get-ItopsServiceSummary -Names @("W32Time")
    $data = @{ services = $services }
    $ok = $services[0].present -and $services[0].status -in @("Running","Stopped")
    Write-ItopsResult -Context $ctx -Result $(if ($ok) {"PASS"} else {"WARN"}) -Message "Collected Windows Time service status." -Data $data -ExitCode $(if ($ok) {0} else {2})

}
