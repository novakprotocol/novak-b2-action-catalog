$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_WORD_PROCESS_COUNT_V1' -Name 'Word process count' -Description 'Counts Word processes without reading documents.' -Kind 'ProcessCount' -IssueArea 'Word' -ActionType 'App self-help check' -Risk 'low' -Targets @('WINWORD') -Hours 24
