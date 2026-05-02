$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_WINGET_COMMAND_PRESENCE_V1' -Name 'Winget command presence' -Description 'Checks whether winget is available without installing or updating anything.' -Kind 'CommandPresence' -IssueArea 'Apps' -ActionType 'Command presence' -Risk 'low' -Targets @('winget.exe') -Hours 24
