# ENDUSER_GET_PROXY_ENABLED_NO_enterpriseLUE_SUMMARY_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_PROXY_ENABLED_NO_enterpriseLUE_SUMMARY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $proxyEnable = $null
    $autoConfigPresent = $false
    try {
        $p = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -ErrorAction Stop
        $proxyEnable = $p.ProxyEnable
        $autoConfigPresent = -not [string]::IsNullOrWhiteSpace($p.AutoConfigURL)
    } catch {}
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected proxy enabled summary without recording proxy values." -Data @{ proxy_enable_value=$proxyEnable; auto_config_url_present=$autoConfigPresent; proxy_values_redacted=$true }

}
