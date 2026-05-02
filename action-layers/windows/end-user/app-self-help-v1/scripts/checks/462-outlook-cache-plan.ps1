$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OUTLOOK_CACHE_PLAN_V1' -Name 'Outlook cache guidance plan' -Description 'Records plan-only cache guidance without touching OST/PST files.' -Kind 'PlanOnly' -IssueArea 'Outlook' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Do not delete OST or PST files from this action layer.', 'Collect evidence first.', 'Escalate cache rebuild or profile repair to approved remediation.') -Hours 24
