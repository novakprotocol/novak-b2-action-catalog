$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$Start = Get-Date
function Step {
    param([string]$Message)
    $Elapsed = [int]((Get-Date) - $Start).TotalSeconds
    Write-Host ""
    Write-Host "===== $Message | elapsed=${Elapsed}s ====="
}

Step "00 :: DISCOVER HELP DESK EVIDENCE ACTIONS"

$Scripts = Get-ChildItem -Path $PSScriptRoot -Filter "*.ps1" -File |
    Where-Object { $_.Name -ne "000-Run-HelpDeskEvidence-V1.ps1" } |
    Sort-Object Name

Write-Host "SCRIPT_COUNT=$($Scripts.Count)"

$Failed = 0
$Index = 0

foreach ($Script in $Scripts) {
    $Index++
    Step ("RUN {0}/{1} :: {2}" -f $Index, $Scripts.Count, $Script.Name)

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Script.FullName
    if ($LASTEXITCODE -ne 0) {
        $Failed++
        Write-Host "SCRIPT_RESULT=FAIL"
    } else {
        Write-Host "SCRIPT_RESULT=PASS"
    }
}

Step "FINAL :: HELP DESK EVIDENCE RUN SUMMARY"

Write-Host "ACTION_ID=ENDUSER_RUN_HELPDESK_EVIDENCE_V1"
if ($Failed -eq 0) {
    Write-Host "RESULT=PASS"
    Write-Host "MESSAGE=All help desk evidence actions completed without script exit failures."
    exit 0
}

Write-Host "RESULT=FAIL"
Write-Host "FAILED_SCRIPT_COUNT=$Failed"
exit 1
