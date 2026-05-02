$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_ACROBAT_CACHE_PLAN_V1' -Name 'Acrobat cache guidance plan' -Description 'Records plan-only Acrobat cache guidance without deleting cache files.' -Kind 'PlanOnly' -IssueArea 'Adobe Acrobat' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Do not clear Acrobat cache from this layer.', 'Close PDFs before any approved cache action.', 'Use approved remediation for cleanup.') -Hours 24
