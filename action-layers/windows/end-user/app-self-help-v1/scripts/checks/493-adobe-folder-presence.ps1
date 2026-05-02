$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_ADOBE_FOLDER_PRESENCE_V1' -Name 'Adobe app data folder presence' -Description 'Checks Adobe app data folder presence without listing contents.' -Kind 'FolderPresence' -IssueArea 'Adobe Acrobat' -ActionType 'Cache visibility check' -Risk 'low' -Targets @('%APPDATA%\Adobe') -Hours 24
