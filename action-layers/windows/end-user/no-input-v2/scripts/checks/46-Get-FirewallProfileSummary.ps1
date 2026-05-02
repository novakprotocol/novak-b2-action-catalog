# ENDUSER_GET_FIREWALL_PROFILE_SUMMARY_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_FIREWALL_PROFILE_SUMMARY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $profiles = @(Get-NetFirewallProfile -ErrorAction Stop | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction)
    $data = @{
        profile_count = $profiles.Count
        profiles = @($profiles | ForEach-Object {
            @{ name=[string]$_.Name; enabled=[bool]$_.Enabled; default_inbound=[string]$_.DefaultInboundAction; default_outbound=[string]$_.DefaultOutboundAction }
        })
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected firewall profile summary." -Data $data

}
