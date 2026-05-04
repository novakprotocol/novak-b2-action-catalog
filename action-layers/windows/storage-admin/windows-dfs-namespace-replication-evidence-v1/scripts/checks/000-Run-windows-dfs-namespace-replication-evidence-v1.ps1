$ErrorActionPreference = 'Continue'
Set-StrictMode -Version 3.0
$Start = Get-Date
function Step([string]$m) {
    $e = [int]((Get-Date) - $Start).TotalSeconds
    Write-Host ""
    Write-Host "===== $m | elapsed=${e}s ====="
}
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Scripts = @(Get-ChildItem -LiteralPath $Here -Filter '*.ps1' | Where-Object { $_.Name -match '^\d+-' -and $_.Name -ne '000-Run-windows-dfs-namespace-replication-evidence-v1.ps1' } | Sort-Object Name)
$Pass = 0
$Fail = 0
foreach ($Script in $Scripts) {
    Step "RUN $($Script.Name)"
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Script.FullName
    if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) { $Pass++ } else { $Fail++ }
}
Write-Host "ACTION_COUNT=$($Scripts.Count)"
Write-Host "PASS_COUNT=$Pass"
Write-Host "FAIL_COUNT=$Fail"
if ($Fail -gt 0) { Write-Host "LOCAL_RUNNER_STATUS=FAIL"; exit 1 }
Write-Host "LOCAL_RUNNER_STATUS=PASS"
exit 0