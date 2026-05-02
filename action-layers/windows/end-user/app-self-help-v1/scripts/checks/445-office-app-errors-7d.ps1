$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OFFICE_APP_ERRORS_7D_V1' -Name 'Office application warning/error count 7d' -Description 'Counts Application log warnings/errors over seven days without collecting raw events.' -Kind 'EventCount' -IssueArea 'Office' -ActionType 'App self-help check' -Risk 'low' -Targets @('Application') -Hours 168
