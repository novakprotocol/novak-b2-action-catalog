$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_EDGE_USER_DATA_FOLDER_PRESENCE_V1' -Name 'Edge user data folder presence' -Description 'Checks Edge user data folder presence without listing contents.' -Kind 'FolderPresence' -IssueArea 'Edge' -ActionType 'Cache visibility check' -Risk 'low' -Targets @('%LOCALAPPDATA%\Microsoft\Edge\User Data') -Hours 24
