$ErrorActionPreference = 'Continue'
Set-StrictMode -Version 3.0
$ExpectedActionCount = 100
$Start = Get-Date

function Step([string]$m) {
    $e = [int]((Get-Date) - $Start).TotalSeconds
    Write-Host ''
    Write-Host "===== $m | elapsed=${e}s ====="
}

$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Scripts = @(Get-ChildItem -LiteralPath $Here -Filter '*.ps1' | Where-Object { $_.Name -match '^\d+-' -and $_.Name -ne '000-Run-enterprise-security-ransomware-storage-evidence-v1.ps1' } | Sort-Object Name)

if ($Scripts.Count -ne $ExpectedActionCount) {
    Write-Host "ACTION_COUNT=$($Scripts.Count)"
    Write-Host 'PASS_COUNT=0'
    Write-Host "FAIL_COUNT=$ExpectedActionCount"
    Write-Host 'LOCAL_RUNNER_STATUS=FAIL'
    Write-Host "ERROR=Expected $ExpectedActionCount scripts but found $($Scripts.Count)"
    exit 1
}

$Pass = 0
$Fail = 0

foreach ($Script in $Scripts) {
    Step "RUN $($Script.Name)"
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Script.FullName
    if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
        $Pass++
    } else {
        $Fail++
    }
}

Write-Host "ACTION_COUNT=$($Scripts.Count)"
Write-Host "PASS_COUNT=$Pass"
Write-Host "FAIL_COUNT=$Fail"

if ($Fail -gt 0) {
    Write-Host 'LOCAL_RUNNER_STATUS=FAIL'
    exit 1
}

Write-Host 'LOCAL_RUNNER_STATUS=PASS'
exit 0