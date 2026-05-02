$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_EDGE_PROCESS_COUNT_V1' -Name 'Edge process count' -Description 'Counts Edge processes without reading browsing data.' -Kind 'ProcessCount' -IssueArea 'Edge' -ActionType 'App self-help check' -Risk 'low' -Targets @('msedge') -Hours 24
