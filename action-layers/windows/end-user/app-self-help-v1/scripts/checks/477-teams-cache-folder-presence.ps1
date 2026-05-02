$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_TEAMS_CACHE_FOLDER_PRESENCE_V1' -Name 'Teams classic cache folder presence' -Description 'Checks Teams classic cache folder presence without listing contents.' -Kind 'FolderPresence' -IssueArea 'Teams' -ActionType 'Cache visibility check' -Risk 'low' -Targets @('%APPDATA%\Microsoft\Teams') -Hours 24
