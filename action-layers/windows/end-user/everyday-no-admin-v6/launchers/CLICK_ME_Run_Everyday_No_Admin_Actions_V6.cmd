@echo off
set SCRIPT_DIR=%~dp0
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%..\scripts\checks\000-Run-Everyday-NoAdmin-Actions-V6.ps1"
pause
