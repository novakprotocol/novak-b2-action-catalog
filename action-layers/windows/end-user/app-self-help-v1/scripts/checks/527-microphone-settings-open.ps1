$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_MICROPHONE_SETTINGS_OPEN_V1' -Name 'Open Microphone privacy settings' -Description 'Opens Windows Microphone privacy settings for user-controlled review.' -Kind 'SettingsOpen' -IssueArea 'Audio' -ActionType 'Open user-help surface' -Risk 'low' -Targets @('ms-settings:privacy-microphone') -Hours 24
