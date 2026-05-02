$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_POWERPOINT_PROCESS_COUNT_V1' -Name 'PowerPoint process count' -Description 'Counts PowerPoint processes without reading presentations.' -Kind 'ProcessCount' -IssueArea 'PowerPoint' -ActionType 'App self-help check' -Risk 'low' -Targets @('POWERPNT') -Hours 24
