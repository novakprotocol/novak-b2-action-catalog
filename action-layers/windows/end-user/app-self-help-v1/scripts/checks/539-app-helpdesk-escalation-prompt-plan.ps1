$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_HELPDESK_ESCALATION_PROMPT_PLAN_V1' -Name 'Help desk escalation prompt plan' -Description 'Records plan-only guidance for ticket-ready escalation after safe self-help.' -Kind 'PlanOnly' -IssueArea 'Help desk evidence' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Summarize user-visible symptom.', 'Attach sanitized local evidence only if policy allows.', 'Do not include credentials, tokens, raw paths, or private file names.') -Hours 24
