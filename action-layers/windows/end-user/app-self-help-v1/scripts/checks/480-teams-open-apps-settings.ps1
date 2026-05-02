$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_TEAMS_OPEN_APPS_SETTINGS_V1' -Name 'Open Apps settings for Teams review' -Description 'Opens Windows Apps settings so the user can inspect Teams installation entries.' -Kind 'SettingsOpen' -IssueArea 'Teams' -ActionType 'Open user-help surface' -Risk 'low' -Targets @('ms-settings:appsfeatures') -Hours 24
