# ENDUSER_SHOW_STORAGE_SELF_CHECK_MENU_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_SHOW_STORAGE_SELF_CHECK_MENU_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    Write-Host ""
    Write-Host "NOenterpriseK B2 Windows Self-Check Menu"
    Write-Host "1. Run all safe local checks"
    Write-Host "2. Test DNS name"
    Write-Host "3. Test ping target"
    Write-Host "4. Test URL status"
    Write-Host "5. Test UNC path access"
    Write-Host "6. Create support evidence bundle"
    Write-Host ""
    $choice = Read-Host "Choose 1-6"
    switch ($choice) {
        "1" { & (Join-Path $ScriptDir "21-Run-AllSafeLocalChecks.ps1") -EvidenceRoot $EvidenceRoot }
        "2" { $n = Read-Host "Enter target DNS name"; & (Join-Path $ScriptDir "04-Test-DnsResolveName.ps1") -TargetName $n -EvidenceRoot $EvidenceRoot }
        "3" { $h = Read-Host "Enter target host"; & (Join-Path $ScriptDir "05-Test-PingTarget.ps1") -TargetHost $h -EvidenceRoot $EvidenceRoot }
        "4" { $u = Read-Host "Enter URL"; & (Join-Path $ScriptDir "07-Test-UrlStatus.ps1") -TargetUrl $u -EvidenceRoot $EvidenceRoot }
        "5" { $p = Read-Host "Enter UNC/folder path"; & (Join-Path $ScriptDir "08-Test-UncPathAccess.ps1") -Path $p -EvidenceRoot $EvidenceRoot }
        "6" { & (Join-Path $ScriptDir "20-New-SupportEvidenceBundle.ps1") -EvidenceRoot $EvidenceRoot }
        default { throw "Invalid menu choice." }
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Menu action completed." -Data @{ choice=$choice }

}
