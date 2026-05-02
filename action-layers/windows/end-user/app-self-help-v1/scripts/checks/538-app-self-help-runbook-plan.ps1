$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_RUNBOOK_PLAN_V1' -Name 'App self-help runbook plan' -Description 'Records plan-only guidance for app self-help workflow.' -Kind 'PlanOnly' -IssueArea 'Support evidence' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Run self-check first.', 'Run safe app self-help actions next.', 'Escalate with evidence if unresolved.') -Hours 24
