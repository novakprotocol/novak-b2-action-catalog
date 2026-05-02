$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OFFICE_FILE_ASSOC_DOCX_V1' -Name 'DOCX association presence' -Description 'Checks whether a DOCX file association is present without recording handler values.' -Kind 'FileAssociationPresence' -IssueArea 'Office' -ActionType 'File association check' -Risk 'low' -Targets @('.docx') -Hours 24
