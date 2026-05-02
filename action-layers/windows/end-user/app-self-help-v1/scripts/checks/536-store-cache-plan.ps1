$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_STORE_CACHE_PLAN_V1' -Name 'Microsoft Store cache guidance plan' -Description 'Records plan-only Microsoft Store cache guidance without running wsreset.' -Kind 'PlanOnly' -IssueArea 'Apps' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Do not run wsreset from this layer.', 'Open Microsoft Store normally first.', 'Use approved remediation for Store reset actions.') -Hours 24
