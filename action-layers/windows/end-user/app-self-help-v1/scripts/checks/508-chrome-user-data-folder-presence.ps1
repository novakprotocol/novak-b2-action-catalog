$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_CHROME_USER_DATA_FOLDER_PRESENCE_V1' -Name 'Chrome user data folder presence' -Description 'Checks Chrome user data folder presence without listing contents.' -Kind 'FolderPresence' -IssueArea 'Chrome' -ActionType 'Cache visibility check' -Risk 'low' -Targets @('%LOCALAPPDATA%\Google\Chrome\User Data') -Hours 24
