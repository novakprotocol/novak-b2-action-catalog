$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_PDF_DEFAULT_APP_PLAN_V1' -Name 'PDF default app guidance plan' -Description 'Records plan-only PDF default app guidance without changing defaults.' -Kind 'PlanOnly' -IssueArea 'PDF / Default apps' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Open Default apps only if user wants to choose a PDF handler.', 'Do not change file associations from this layer.', 'Escalate locked default app policy to help desk.') -Hours 24
