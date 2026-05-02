# ENDUSER_TEST_PING_TARGET_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_TEST_PING_TARGET_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    if ([string]::IsNullOrWhiteSpace($TargetHost)) { throw "TargetHost is required at runtime." }
    $ok = Test-Connection -ComputerName $TargetHost -Count 3 -Quiet -ErrorAction SilentlyContinue
    $data = @{
        target_input_runtime_supplied = $true
        target_host = $TargetHost
        ping_replied = [bool]$ok
        note = "ICMP may be blocked by policy; failure does not prove the service is down."
    }
    if ($ok) {
        Write-ItopsResult -Context $ctx -Result "PASS" -Message "Target replied to ping." -Data $data
    } else {
        Write-ItopsResult -Context $ctx -Result "WARN" -Message "Target did not reply to ping or ICMP is blocked." -Data $data -ExitCode 2
    }

}
