$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_PROXY_SETTINGS_OPEN_V1' -Name 'Open Proxy settings' -Description 'Opens Windows Proxy settings for user-controlled review.' -Kind 'SettingsOpen' -IssueArea 'Network' -ActionType 'Open user-help surface' -Risk 'low' -Targets @('ms-settings:network-proxy') -Hours 24
