$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_KEYBOARD_SETTINGS_OPEN_V1' -Name 'Open Keyboard settings' -Description 'Opens Windows Keyboard settings for user-controlled review.' -Kind 'SettingsOpen' -IssueArea 'Input' -ActionType 'Open user-help surface' -Risk 'low' -Targets @('ms-settings:easeofaccess-keyboard') -Hours 24
