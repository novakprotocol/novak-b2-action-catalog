# ENDUSER_GET_WINHTTP_PROXY_NO_enterpriseLUE_SUMMARY_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_WINHTTP_PROXY_NO_enterpriseLUE_SUMMARY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $configured = $null
    try {
        $out = netsh winhttp show proxy 2>$null | Out-String
        if ($out -match "Direct access") { $configured = $false }
        elseif ($out -match "Proxy Server") { $configured = $true }
    } catch {}
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected WinHTTP proxy configured flag without recording proxy values." -Data @{ winhttp_proxy_configured=$configured; proxy_values_redacted=$true }

}
