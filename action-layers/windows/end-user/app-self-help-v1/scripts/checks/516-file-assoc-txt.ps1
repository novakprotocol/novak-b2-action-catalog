$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_FILE_ASSOC_TXT_V1' -Name 'TXT file association presence' -Description 'Checks TXT file association presence without recording handler values.' -Kind 'FileAssociationPresence' -IssueArea 'Default apps' -ActionType 'File association check' -Risk 'low' -Targets @('.txt') -Hours 24
