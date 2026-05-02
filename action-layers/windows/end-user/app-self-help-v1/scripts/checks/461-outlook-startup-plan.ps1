$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OUTLOOK_STARTUP_PLAN_V1' -Name 'Outlook startup plan' -Description 'Records plan-only Outlook startup guidance without closing Outlook or changing data.' -Kind 'PlanOnly' -IssueArea 'Outlook' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Check whether Outlook is already running.', 'Try launching Outlook normally.', 'Use safe mode only if local support policy allows it.', 'Escalate with evidence if profile repair is needed.') -Hours 24
