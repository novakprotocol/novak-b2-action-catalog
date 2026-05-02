$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_CHROME_CACHE_CLEAR_PLAN_V1' -Name 'Chrome cache guidance plan' -Description 'Records plan-only Chrome cache guidance without deleting cache files.' -Kind 'PlanOnly' -IssueArea 'Chrome' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Do not clear Chrome cache from this layer.', 'Use browser UI if user chooses.', 'Use approved remediation for forced cleanup.') -Hours 24
