@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\checks\000-Run-linux-storage-host-fleet-evidence-v1.ps1"
pause