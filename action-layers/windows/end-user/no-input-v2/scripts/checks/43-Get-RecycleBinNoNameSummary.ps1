# ENDUSER_GET_RECYCLE_BIN_NO_NAME_SUMMARY_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_RECYCLE_BIN_NO_NAME_SUMMARY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $shell = New-Object -ComObject Shell.Application
    $bin = $shell.Namespace(10)
    $items = @($bin.Items())
    $count = $items.Count
    $size = 0
    foreach ($i in $items) { try { $size += [int64]$i.Size } catch {} }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected Recycle Bin item count and approximate size without item names." -Data @{ item_count=$count; approximate_size_mb=[math]::Round($size/1MB,2); item_names_redacted=$true }

}
