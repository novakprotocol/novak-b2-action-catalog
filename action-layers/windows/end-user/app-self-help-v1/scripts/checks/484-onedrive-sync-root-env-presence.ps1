$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_ONEDRIVE_SYNC_ROOT_ENV_PRESENCE_V1' -Name 'OneDrive sync environment presence' -Description 'Checks OneDrive environment variable presence without recording values.' -Kind 'EnvironmentPresence' -IssueArea 'OneDrive' -ActionType 'Environment presence' -Risk 'low' -Targets @('OneDrive', 'OneDriveCommercial', 'OneDriveConsumer') -Hours 24
