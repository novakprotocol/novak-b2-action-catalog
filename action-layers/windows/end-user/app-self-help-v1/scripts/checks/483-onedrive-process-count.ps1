$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_ONEDRIVE_PROCESS_COUNT_V1' -Name 'OneDrive process count' -Description 'Counts OneDrive processes without reading synced file names.' -Kind 'ProcessCount' -IssueArea 'OneDrive' -ActionType 'App self-help check' -Risk 'low' -Targets @('OneDrive') -Hours 24
