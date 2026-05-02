$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_PDF_FILE_ASSOC_V1' -Name 'PDF association presence' -Description 'Checks whether a PDF file association is present without recording handler values.' -Kind 'FileAssociationPresence' -IssueArea 'PDF / Default apps' -ActionType 'File association check' -Risk 'low' -Targets @('.pdf') -Hours 24
