# ENDUSER_TEST_HTTPS_PORT_443_V1
# NOenterpriseK B2 Windows End User Easy Button Script
# Safe boundary: read-only, current-user context, no credentials, no mutation, no target inventory in code.

[CmdletBinding()]
param(
    [string]$TargetHost,
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SafeEvidence.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_TEST_HTTPS_PORT_443_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    if ([string]::IsNullOrWhiteSpace($TargetHost)) { throw "TargetHost is required at runtime." }
    $result = Test-NetConnection -ComputerName $TargetHost -Port 443 -WarningAction SilentlyContinue
    $ok = [bool]$result.TcpTestSucceeded
    $data = @{ target_host=$TargetHost; port=443; tcp_test_succeeded=$ok }
    Write-ItopsResult -Context $ctx -Result $(if ($ok) {"PASS"} else {"FAIL"}) -Message $(if ($ok) {"HTTPS TCP 443 reachable."} else {"HTTPS TCP 443 not reachable."}) -Data $data -ExitCode $(if ($ok) {0} else {1})

}
