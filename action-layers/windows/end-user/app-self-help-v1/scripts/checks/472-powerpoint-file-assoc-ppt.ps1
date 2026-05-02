$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_POWERPOINT_FILE_ASSOC_PPT_V1' -Name 'PPT association presence' -Description 'Checks whether a PPT file association is present without recording handler values.' -Kind 'FileAssociationPresence' -IssueArea 'PowerPoint' -ActionType 'File association check' -Risk 'low' -Targets @('.ppt') -Hours 24
