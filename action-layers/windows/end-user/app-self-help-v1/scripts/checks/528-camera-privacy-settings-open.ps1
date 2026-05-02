$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_CAMERA_PRIVACY_SETTINGS_OPEN_V1' -Name 'Open Camera privacy settings' -Description 'Opens Windows Camera privacy settings for user-controlled review.' -Kind 'SettingsOpen' -IssueArea 'Camera' -ActionType 'Open user-help surface' -Risk 'low' -Targets @('ms-settings:privacy-webcam') -Hours 24
