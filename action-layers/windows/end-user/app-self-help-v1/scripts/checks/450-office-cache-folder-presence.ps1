$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OFFICE_CACHE_FOLDER_PRESENCE_V1' -Name 'Office cache folder presence' -Description 'Checks common Office cache folder presence without listing contents.' -Kind 'FolderPresence' -IssueArea 'Office' -ActionType 'Cache visibility check' -Risk 'low' -Targets @('%LOCALAPPDATA%\Microsoft\Office') -Hours 24
