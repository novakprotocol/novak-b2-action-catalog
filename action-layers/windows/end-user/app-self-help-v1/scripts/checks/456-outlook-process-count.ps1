$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OUTLOOK_PROCESS_COUNT_V1' -Name 'Outlook process count' -Description 'Counts Outlook processes without reading mail or profile contents.' -Kind 'ProcessCount' -IssueArea 'Outlook' -ActionType 'App self-help check' -Risk 'low' -Targets @('OUTLOOK') -Hours 24
