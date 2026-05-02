$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_ONEDRIVE_OPEN_FOLDER_PLAN_V1' -Name 'OneDrive open-folder guidance plan' -Description 'Records plan-only OneDrive folder guidance without opening private paths.' -Kind 'PlanOnly' -IssueArea 'OneDrive' -ActionType 'Plan-only guidance' -Risk 'low' -Targets @('Use File Explorer OneDrive icon if visible.', 'Do not record or commit synced paths.', 'Escalate missing sync root with evidence.') -Hours 24
