# ENDUSER_RUN_ALL_SAFE_LOCAL_CHECKS_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_RUN_ALL_SAFE_LOCAL_CHECKS_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $bundleDir = $ctx.RunDir
    $checks = @(
        "01-Get-UserComputerContext.ps1",
        "02-Get-NetworkAdapterStatus.ps1",
        "03-Get-DnsClientSummary.ps1",
        "10-Get-MappedDrives.ps1",
        "11-Test-MappedDrives.ps1",
        "12-Get-LocalDriveSpace.ps1",
        "13-Get-OneDriveBasicStatus.ps1",
        "14-Get-SmbClientBasicStatus.ps1",
        "15-Get-SmbConnections.ps1",
        "16-Get-RecentStorageRelatedEvents.ps1",
        "17-Get-GpResultUserSummary.ps1"
    )
    $results = @()
    foreach ($c in $checks) {
        $path = Join-Path $ScriptDir $c
        try {
            powershell.exe -NoProfile -ExecutionPolicy Bypass -File $path -EvidenceRoot $bundleDir
            $results += @{ check=$c; launched=$true; exit_code=$LASTEXITCODE }
        } catch {
            $results += @{ check=$c; launched=$false; error=$_.Exception.Message }
        }
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Ran safe local checks." -Data @{ run_dir=$bundleDir; checks=$results }

}
