@echo off
set SCRIPT_DIR=%~dp0
echo This launcher runs DRY-RUN PLAN ONLY. It does not apply fixes.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%..\scripts\fixes\000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1"
pause
