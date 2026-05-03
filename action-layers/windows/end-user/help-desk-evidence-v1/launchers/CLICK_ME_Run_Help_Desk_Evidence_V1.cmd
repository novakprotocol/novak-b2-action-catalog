@echo off
setlocal
cd /d %~dp0\..\
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%cd%\scripts\checks\000-Run-HelpDeskEvidence-V1.ps1"
set EXITCODE=%ERRORLEVEL%
echo.
echo Help Desk Evidence V1 finished with exit code %EXITCODE%.
pause
exit /b %EXITCODE%
