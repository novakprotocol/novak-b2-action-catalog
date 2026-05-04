@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\checks\000-Run-enterprise-san-fabric-evidence-v1.ps1"
pause