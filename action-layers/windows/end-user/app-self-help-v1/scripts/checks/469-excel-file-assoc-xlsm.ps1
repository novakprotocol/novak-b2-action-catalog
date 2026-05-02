$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_EXCEL_FILE_ASSOC_XLSM_V1' -Name 'XLSM association presence' -Description 'Checks whether an XLSM file association is present without recording handler values.' -Kind 'FileAssociationPresence' -IssueArea 'Excel' -ActionType 'File association check' -Risk 'low' -Targets @('.xlsm') -Hours 24
