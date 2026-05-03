@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\checks\000-Run-NetworkEvidence-V1.ps1"
exit /b %ERRORLEVEL%