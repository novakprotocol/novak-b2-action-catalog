$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_EXCEL_FILE_ASSOC_XLS_V1' -Name 'XLS association presence' -Description 'Checks whether an XLS file association is present without recording handler values.' -Kind 'FileAssociationPresence' -IssueArea 'Excel' -ActionType 'File association check' -Risk 'low' -Targets @('.xls') -Hours 24
