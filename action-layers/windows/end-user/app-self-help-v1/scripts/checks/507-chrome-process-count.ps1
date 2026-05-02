$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_CHROME_PROCESS_COUNT_V1' -Name 'Chrome process count' -Description 'Counts Chrome processes without reading browsing data.' -Kind 'ProcessCount' -IssueArea 'Chrome' -ActionType 'App self-help check' -Risk 'low' -Targets @('chrome') -Hours 24
