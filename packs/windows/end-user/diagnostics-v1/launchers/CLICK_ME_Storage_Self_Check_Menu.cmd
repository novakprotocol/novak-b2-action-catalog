@echo off
set SCRIPT_DIR=%~dp0
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%..\scripts\checks\22-Show-StorageSelfCheckMenu.ps1"
pause
