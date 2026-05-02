$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OFFICE_CLICKTORUN_SERVICE_STATUS_V2' -Name 'Office ClickToRun service status' -Description 'Checks the Microsoft Office ClickToRun service status without changing it.' -Kind 'ServiceStatus' -IssueArea 'Office' -ActionType 'App self-help check' -Risk 'low' -Targets @('ClickToRunSvc') -Hours 24
