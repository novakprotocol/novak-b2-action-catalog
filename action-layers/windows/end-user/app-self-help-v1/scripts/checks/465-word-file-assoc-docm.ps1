$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_WORD_FILE_ASSOC_DOCM_V1' -Name 'DOCM association presence' -Description 'Checks whether a DOCM file association is present without recording handler values.' -Kind 'FileAssociationPresence' -IssueArea 'Word' -ActionType 'File association check' -Risk 'low' -Targets @('.docm') -Hours 24
