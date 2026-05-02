# ENDUSER_GET_DOMAIN_JOIN_SUMMARY_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_DOMAIN_JOIN_SUMMARY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $cs = Get-CimInstance Win32_ComputerSystem
    $data = @{
        part_of_domain = [bool]$cs.PartOfDomain
        domain_or_workgroup_value_present = -not [string]::IsNullOrWhiteSpace($cs.Domain)
        domain_name_redacted = $true
        role = [string]$cs.DomainRole
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected domain/workgroup summary without recording domain value." -Data $data

}
