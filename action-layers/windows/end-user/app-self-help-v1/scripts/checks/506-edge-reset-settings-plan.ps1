$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_EDGE_RESET_SETTINGS_PLAN_V1' -Name 'Edge reset settings guidance plan' -Description 'Records plan-only Edge reset guidance without changing settings.' -Kind 'PlanOnly' -IssueArea 'Edge' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Do not reset Edge settings from this layer.', 'Collect evidence first.', 'Escalate managed browser policy issues.') -Hours 24
