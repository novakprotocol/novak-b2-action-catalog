$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OFFICE_ENV_PRESENCE_V2' -Name 'Office environment signal presence' -Description 'Checks selected Office-related environment variable presence without recording values.' -Kind 'EnvironmentPresence' -IssueArea 'Office' -ActionType 'Environment presence' -Risk 'low' -Targets @('OneDrive', 'OneDriveCommercial', 'OneDriveConsumer') -Hours 24
