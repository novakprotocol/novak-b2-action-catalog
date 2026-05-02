$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_ACROBAT_RESTART_PLAN_V1' -Name 'Acrobat restart guidance plan' -Description 'Records plan-only Acrobat restart guidance without closing Acrobat.' -Kind 'PlanOnly' -IssueArea 'Adobe Acrobat' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Ask user to save PDFs first.', 'Use normal app close if needed.', 'Do not force-kill Acrobat from this layer.') -Hours 24
