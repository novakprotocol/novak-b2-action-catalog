$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_SCANNER_CAMERA_SETTINGS_OPEN_V1' -Name 'Open Bluetooth & devices settings' -Description 'Opens Windows Bluetooth & devices settings for printer/scanner review.' -Kind 'SettingsOpen' -IssueArea 'Devices' -ActionType 'Open user-help surface' -Risk 'low' -Targets @('ms-settings:bluetooth') -Hours 24
