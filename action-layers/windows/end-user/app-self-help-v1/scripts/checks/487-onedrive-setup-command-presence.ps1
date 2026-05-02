$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_ONEDRIVE_SETUP_COMMAND_PRESENCE_V1' -Name 'OneDrive setup command presence' -Description 'Checks common OneDrive setup command presence without launching it.' -Kind 'CommandPresence' -IssueArea 'OneDrive' -ActionType 'Command presence' -Risk 'low' -Targets @('OneDriveSetup.exe') -Hours 24
