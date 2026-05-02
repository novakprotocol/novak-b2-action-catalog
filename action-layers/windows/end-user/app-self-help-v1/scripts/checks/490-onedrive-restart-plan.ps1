$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_ONEDRIVE_RESTART_PLAN_V1' -Name 'OneDrive restart guidance plan' -Description 'Records plan-only OneDrive restart guidance without closing OneDrive.' -Kind 'PlanOnly' -IssueArea 'OneDrive' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Ask user to confirm sync status first.', 'Do not force-kill OneDrive from this layer.', 'Use approved remediation for restart actions.') -Hours 24
