# ENDUSER_TEST_DNS_RESOLVE_NAME_V1
# NOenterpriseK B2 Windows End User Easy Button Script
# Safe boundary: read-only, current-user context, no credentials, no mutation, no target inventory in code.

[CmdletBinding()]
param(
    [string]$TargetName,
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SafeEvidence.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_TEST_DNS_RESOLVE_NAME_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    if ([string]::IsNullOrWhiteSpace($TargetName)) { throw "TargetName is required at runtime." }
    $resolved = $false
    $records = @()
    try {
        $records = @(Resolve-DnsName -Name $TargetName -ErrorAction Stop | Select-Object -First 10)
        $resolved = $records.Count -gt 0
    } catch {
        $records = @()
    }
    $data = @{
        target_input_runtime_supplied = $true
        target_name = $TargetName
        resolved = $resolved
        record_count = $records.Count
        record_types = @($records | Select-Object -ExpandProperty Type -Unique)
    }
    if ($resolved) {
        Write-ItopsResult -Context $ctx -Result "PASS" -Message "DNS resolution returned at least one record." -Data $data
    } else {
        Write-ItopsResult -Context $ctx -Result "FAIL" -Message "DNS resolution failed or returned no records." -Data $data -ExitCode 1
    }

}
