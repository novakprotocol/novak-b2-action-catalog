$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_DISPLAY_SETTINGS_OPEN_V1' -Name 'Open Display settings' -Description 'Opens Windows Display settings for user-controlled review.' -Kind 'SettingsOpen' -IssueArea 'Display' -ActionType 'Open user-help surface' -Risk 'low' -Targets @('ms-settings:display') -Hours 24
