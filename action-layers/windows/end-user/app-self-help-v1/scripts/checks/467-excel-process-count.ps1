$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_EXCEL_PROCESS_COUNT_V1' -Name 'Excel process count' -Description 'Counts Excel processes without reading workbooks.' -Kind 'ProcessCount' -IssueArea 'Excel' -ActionType 'App self-help check' -Risk 'low' -Targets @('EXCEL') -Hours 24
