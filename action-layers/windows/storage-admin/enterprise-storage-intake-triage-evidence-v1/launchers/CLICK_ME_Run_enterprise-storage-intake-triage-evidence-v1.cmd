@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\checks\000-Run-enterprise-storage-intake-triage-evidence-v1.ps1"
pause