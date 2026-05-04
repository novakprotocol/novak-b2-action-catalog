@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\checks\000-Run-enterprise-backup-dr-resilience-evidence-v1.ps1"
pause