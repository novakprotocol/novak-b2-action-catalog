@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\checks\000-Run-windows-vss-restore-readiness-evidence-v1.ps1"
pause
