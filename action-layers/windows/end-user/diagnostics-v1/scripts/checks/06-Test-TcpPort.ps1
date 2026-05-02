# ENDUSER_TEST_TCP_PORT_V1
# NOenterpriseK B2 Windows End User Easy Button Script
# Safe boundary: read-only, current-user context, no credentials, no mutation, no target inventory in code.

[CmdletBinding()]
param(
    [string]$TargetHost,
    [int]$TargetPort,
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SafeEvidence.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_TEST_TCP_PORT_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    if ([string]::IsNullOrWhiteSpace($TargetHost)) { throw "TargetHost is required at runtime." }
    if ($TargetPort -le 0 -or $TargetPort -gt 65535) { throw "TargetPort must be 1-65535." }
    $result = Test-NetConnection -ComputerName $TargetHost -Port $TargetPort -WarningAction SilentlyContinue
    $ok = [bool]$result.TcpTestSucceeded
    $data = @{
        target_input_runtime_supplied = $true
        target_host = $TargetHost
        target_port = $TargetPort
        tcp_test_succeeded = $ok
    }
    if ($ok) {
        Write-ItopsResult -Context $ctx -Result "PASS" -Message "TCP port is reachable." -Data $data
    } else {
        Write-ItopsResult -Context $ctx -Result "FAIL" -Message "TCP port is not reachable." -Data $data -ExitCode 1
    }

}
