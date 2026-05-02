$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OFFICE_OPEN_DEFAULT_APPS_SETTINGS_V1' -Name 'Open Default apps settings' -Description 'Opens Windows Default apps settings for Office file association review.' -Kind 'SettingsOpen' -IssueArea 'Office' -ActionType 'Open user-help surface' -Risk 'low' -Targets @('ms-settings:defaultapps') -Hours 24
