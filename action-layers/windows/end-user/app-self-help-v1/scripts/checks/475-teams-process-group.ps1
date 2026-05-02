$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_TEAMS_PROCESS_GROUP_V1' -Name 'Teams process group count' -Description 'Counts Teams processes without reading chat data.' -Kind 'ProcessCount' -IssueArea 'Teams' -ActionType 'App self-help check' -Risk 'low' -Targets @('Teams', 'ms-teams', 'msteams') -Hours 24
