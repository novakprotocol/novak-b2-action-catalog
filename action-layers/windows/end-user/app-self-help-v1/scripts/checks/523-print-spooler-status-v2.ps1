$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_PRINT_SPOOLER_STATUS_V2' -Name 'Print Spooler service status' -Description 'Checks Print Spooler service status without changing it.' -Kind 'ServiceStatus' -IssueArea 'Printers' -ActionType 'App self-help check' -Risk 'low' -Targets @('Spooler') -Hours 24
