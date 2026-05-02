$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_SAFETY_BOUNDARY_V1' -Name 'App self-help safety boundary' -Description 'Records the safety boundary for app self-help actions without changing the system.' -Kind 'PlanOnly' -IssueArea 'Governance' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('No admin actions.', 'No credentials.', 'No target lists.', 'No mutation unless explicitly approved.', 'Help desk escalation when safe self-help does not resolve the issue.') -Hours 24
