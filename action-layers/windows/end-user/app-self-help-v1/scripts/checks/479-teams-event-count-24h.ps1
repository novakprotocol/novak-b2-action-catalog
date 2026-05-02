$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_TEAMS_EVENT_COUNT_24H_V1' -Name 'Teams adjacent event count 24h' -Description 'Counts recent Application warnings/errors as a Teams-adjacent signal without collecting raw events.' -Kind 'EventCount' -IssueArea 'Teams' -ActionType 'App self-help check' -Risk 'low' -Targets @('Application') -Hours 24
