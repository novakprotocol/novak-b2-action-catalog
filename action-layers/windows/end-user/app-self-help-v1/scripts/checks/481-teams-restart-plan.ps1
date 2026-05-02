$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_TEAMS_RESTART_PLAN_V1' -Name 'Teams restart guidance plan' -Description 'Records plan-only Teams restart guidance without closing Teams.' -Kind 'PlanOnly' -IssueArea 'Teams' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Ask user to save work and close calls first.', 'Use normal Quit from Teams tray if available.', 'Do not force-kill Teams from this layer.') -Hours 24
