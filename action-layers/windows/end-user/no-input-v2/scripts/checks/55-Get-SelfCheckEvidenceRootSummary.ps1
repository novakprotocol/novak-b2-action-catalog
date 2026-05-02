# ENDUSER_GET_SELFCHECK_EVIDENCE_ROOT_SUMMARY_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_SELFCHECK_EVIDENCE_ROOT_SUMMARY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $root = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "NOenterpriseK-B2-Windows-SelfCheck"
    $exists = Test-Path -LiteralPath $root -PathType Container
    $dirCount = 0
    $fileCount = 0
    $sizeBytes = 0
    if ($exists) {
        $dirs = @(Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue)
        $files = @(Get-ChildItem -LiteralPath $root -File -Recurse -ErrorAction SilentlyContinue)
        $dirCount = $dirs.Count
        $fileCount = $files.Count
        foreach ($f in $files) { $sizeBytes += $f.Length }
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected NOenterpriseK B2 self-check evidence root summary." -Data @{ evidence_root_exists=$exists; run_folder_count=$dirCount; file_count=$fileCount; size_mb=[math]::Round($sizeBytes/1MB,2); path_redacted=$true }

}
