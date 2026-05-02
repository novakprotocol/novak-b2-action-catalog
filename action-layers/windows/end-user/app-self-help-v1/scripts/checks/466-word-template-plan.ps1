$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_WORD_TEMPLATE_PLAN_V1' -Name 'Word template guidance plan' -Description 'Records plan-only Word template guidance without changing templates.' -Kind 'PlanOnly' -IssueArea 'Word' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Do not delete or rename Normal.dotm from this layer.', 'Collect evidence and escalate if template reset is required.', 'Use approved remediation for template changes.') -Hours 24
