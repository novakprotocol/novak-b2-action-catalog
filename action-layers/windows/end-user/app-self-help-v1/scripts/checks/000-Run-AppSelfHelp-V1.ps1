$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0
$Start = Get-Date
function Step { param([string]$Message) $Elapsed=[int]((Get-Date)-$Start).TotalSeconds; Write-Host ""; Write-Host "===== $Message | elapsed=${Elapsed}s =====" }
$ScriptDir=Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath=Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath
Step "00 :: DISCOVER APP SELF-HELP ACTIONS"
$Scripts=Get-ChildItem -LiteralPath $ScriptDir -Filter "*.ps1" -File | Where-Object { $_.Name -ne "000-Run-AppSelfHelp-V1.ps1" } | Sort-Object Name
Write-Host "SCRIPT_COUNT=$($Scripts.Count)"
$Failures=New-Object System.Collections.Generic.List[object]
$Index=0
foreach ($Script in $Scripts) {
    $Index++
    Step ("RUN {0}/{1} :: {2}" -f $Index, $Scripts.Count, $Script.Name)
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Script.FullName
    if ($LASTEXITCODE -ne 0) { $Failures.Add([pscustomobject]@{ script=$Script.Name; exit_code=$LASTEXITCODE }) | Out-Null }
}
Step "FINAL :: WRITE RUN SUMMARY"
if ($Failures.Count -eq 0) { $Result="PASS"; $Message="All app self-help actions completed without script exit failures." } else { $Result="WARN"; $Message="One or more app self-help actions reported script exit failures." }
$Data=[ordered]@{ script_count=$Scripts.Count; failure_count=$Failures.Count; failures=$Failures; elapsed_seconds=[int]((Get-Date)-$Start).TotalSeconds }
Write-AppSelfHelpEvidence -ActionId "ENDUSER_RUN_APP_SELF_HELP_V1" -Result $Result -Message $Message -Data $Data

