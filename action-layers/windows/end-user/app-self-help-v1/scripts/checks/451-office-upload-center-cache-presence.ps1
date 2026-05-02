$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OFFICE_UPLOAD_CENTER_CACHE_PRESENCE_V1' -Name 'Office upload cache folder presence' -Description 'Checks Office upload cache folder presence without listing contents.' -Kind 'FolderPresence' -IssueArea 'Office' -ActionType 'Cache visibility check' -Risk 'low' -Targets @('%LOCALAPPDATA%\Microsoft\Office\16.0\OfficeFileCache') -Hours 24
