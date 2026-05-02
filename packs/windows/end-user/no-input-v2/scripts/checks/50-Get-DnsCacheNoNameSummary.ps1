# ENDUSER_GET_DNS_CACHE_NO_NAME_SUMMARY_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_DNS_CACHE_NO_NAME_SUMMARY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $cache = @()
    try { $cache = @(Get-DnsClientCache -ErrorAction Stop) } catch {}
    $types = @{}
    foreach ($c in $cache) {
        $t = [string]$c.Type
        if (-not $types.ContainsKey($t)) { $types[$t] = 0 }
        $types[$t]++
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected DNS cache count and type summary without recording names." -Data @{ cache_count=$cache.Count; type_counts=$types; names_redacted=$true }

}
