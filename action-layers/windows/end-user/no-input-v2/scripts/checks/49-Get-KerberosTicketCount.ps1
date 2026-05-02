# ENDUSER_GET_KERBEROS_TICKET_COUNT_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_KERBEROS_TICKET_COUNT_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $count = $null
    $available = $false
    try {
        $out = klist.exe 2>$null | Out-String
        $available = $true
        $count = ([regex]::Matches($out, "Server:")).Count
    } catch {}
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected Kerberos ticket count without recording ticket names." -Data @{ klist_available=$available; ticket_count=$count; ticket_names_redacted=$true }

}
