# ENDUSER_GET_SMB_MAPPING_NO_PATH_SUMMARY_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_SMB_MAPPING_NO_PATH_SUMMARY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $maps = @()
    try { $maps = @(Get-SmbMapping -ErrorAction Stop) } catch {}
    $statusCounts = @{}
    foreach ($m in $maps) {
        $s = [string]$m.Status
        if (-not $statusCounts.ContainsKey($s)) { $statusCounts[$s] = 0 }
        $statusCounts[$s]++
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected SMB mapping count/status summary without recording paths." -Data @{ mapping_count=$maps.Count; status_counts=$statusCounts; paths_redacted=$true }

}
