# Bootstrap-NOVAK-B2-Action-Catalog.ps1
# Run from the extracted novak-b2-action-catalog folder.

$ErrorActionPreference = "Stop"

$RemoteUrl = "https://github.com/novakprotocol/novak-b2-action-catalog.git"

Write-Host "===== Validating PowerShell syntax ====="
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\powershell\Test-AllPowerShellSyntax.ps1

Write-Host "===== Validating catalog ====="
python .\tools\python\validate_action_index.py
python .\tools\python\validate_no_secrets_or_targets.py

Write-Host "===== Git init ====="
if (-not (Test-Path ".git")) {
    git init
}
git branch -M main

git add -A
git status --short

git commit -m "Initialize NOVAK B2 Action Catalog public action source"

if ((git remote | Select-String -Pattern "^origin$").Count -eq 0) {
    git remote add origin $RemoteUrl
} else {
    git remote set-url origin $RemoteUrl
}

git remote -v

Write-Host "===== Push ====="
git push -u origin main
