$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_CHROME_RESET_SETTINGS_PLAN_V1' -Name 'Chrome reset settings guidance plan' -Description 'Records plan-only Chrome reset guidance without changing settings.' -Kind 'PlanOnly' -IssueArea 'Chrome' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Do not reset Chrome settings from this layer.', 'Collect evidence first.', 'Escalate managed browser policy issues.') -Hours 24
