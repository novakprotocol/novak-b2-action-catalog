$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OFFICE_REPAIR_GUIDANCE_PLAN_V1' -Name 'Office repair guidance plan' -Description 'Records plan-only guidance for Office repair escalation without changing the system.' -Kind 'PlanOnly' -IssueArea 'Office' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Use Settings > Apps > Installed apps > Microsoft 365 > Modify only if approved by local policy.', 'Close Office files and confirm backups before repair.', 'Escalate with evidence if repair requires admin approval.') -Hours 24
