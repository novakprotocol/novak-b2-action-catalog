@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\checks\000-Run-windows-dfs-namespace-replication-evidence-v1.ps1"
pause
