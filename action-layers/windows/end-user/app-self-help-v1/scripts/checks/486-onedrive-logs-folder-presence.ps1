$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_ONEDRIVE_LOGS_FOLDER_PRESENCE_V1' -Name 'OneDrive logs folder presence' -Description 'Checks OneDrive logs folder presence without listing log contents.' -Kind 'FolderPresence' -IssueArea 'OneDrive' -ActionType 'Cache visibility check' -Risk 'low' -Targets @('%LOCALAPPDATA%\Microsoft\OneDrive\logs') -Hours 24
