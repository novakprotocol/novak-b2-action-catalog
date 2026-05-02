$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_EXCEL_SAFE_MODE_PLAN_V1' -Name 'Excel safe mode guidance plan' -Description 'Records plan-only Excel safe mode guidance without launching or changing Excel.' -Kind 'PlanOnly' -IssueArea 'Excel' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Try Excel normally first.', 'Use safe mode only if approved by support instructions.', 'Do not disable add-ins from this layer.') -Hours 24
