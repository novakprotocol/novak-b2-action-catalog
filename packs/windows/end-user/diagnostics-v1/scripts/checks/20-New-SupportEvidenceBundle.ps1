# ENDUSER_NEW_SUPPORT_EVIDENCE_BUNDLE_V1
# NOenterpriseK B2 Windows End User Easy Button Script
# Safe boundary: read-only, current-user context, no credentials, no mutation, no target inventory in code.

[CmdletBinding()]
param(
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SafeEvidence.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_NEW_SUPPORT_EVIDENCE_BUNDLE_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $bundleDir = $ctx.RunDir
    & (Join-Path $ScriptDir "01-Get-UserComputerContext.ps1") -EvidenceRoot $bundleDir
    & (Join-Path $ScriptDir "02-Get-NetworkAdapterStatus.ps1") -EvidenceRoot $bundleDir
    & (Join-Path $ScriptDir "03-Get-DnsClientSummary.ps1") -EvidenceRoot $bundleDir
    & (Join-Path $ScriptDir "10-Get-MappedDrives.ps1") -EvidenceRoot $bundleDir
    & (Join-Path $ScriptDir "11-Test-MappedDrives.ps1") -EvidenceRoot $bundleDir
    & (Join-Path $ScriptDir "12-Get-LocalDriveSpace.ps1") -EvidenceRoot $bundleDir
    & (Join-Path $ScriptDir "13-Get-OneDriveBasicStatus.ps1") -EvidenceRoot $bundleDir
    $zipPath = "$bundleDir.zip"
    Compress-Archive -Path (Join-Path $bundleDir "*") -DestinationPath $zipPath -Force
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Created support evidence bundle." -Data @{ bundle_dir=$bundleDir; zip_path=$zipPath; review_before_sending=$true }

}
