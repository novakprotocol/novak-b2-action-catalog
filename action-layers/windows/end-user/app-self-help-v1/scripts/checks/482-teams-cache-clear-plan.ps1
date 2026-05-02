$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_TEAMS_CACHE_CLEAR_PLAN_V1' -Name 'Teams cache guidance plan' -Description 'Records plan-only Teams cache guidance without deleting cache files.' -Kind 'PlanOnly' -IssueArea 'Teams' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Do not clear Teams cache from this layer.', 'Collect evidence first.', 'Use approved remediation for cache deletion.') -Hours 24
