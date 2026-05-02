@echo off
setlocal
cd /d %~dp0\..
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\checks\000-Run-AppSelfHelp-V1.ps1
pause
