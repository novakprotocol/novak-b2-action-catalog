@echo off
set SCRIPT_DIR=%~dp0
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%..\scripts\checks\60-Run-AllNoInputChecks-V2.ps1"
pause
