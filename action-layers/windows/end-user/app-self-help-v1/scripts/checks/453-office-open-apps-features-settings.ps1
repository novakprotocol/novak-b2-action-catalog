$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OFFICE_OPEN_APPS_FEATURES_SETTINGS_V1' -Name 'Open Apps & features settings' -Description 'Opens Windows Apps & features so the user can inspect Office install entries.' -Kind 'SettingsOpen' -IssueArea 'Office' -ActionType 'Open user-help surface' -Risk 'low' -Targets @('ms-settings:appsfeatures') -Hours 24
