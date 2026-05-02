$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_EDGE_CACHE_CLEAR_PLAN_V1' -Name 'Edge cache guidance plan' -Description 'Records plan-only Edge cache guidance without deleting cache files.' -Kind 'PlanOnly' -IssueArea 'Edge' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Do not clear Edge cache from this layer.', 'Use browser UI if user chooses.', 'Use approved remediation for forced cleanup.') -Hours 24
