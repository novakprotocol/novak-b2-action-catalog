$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_FILE_ASSOC_HTM_V1' -Name 'HTM file association presence' -Description 'Checks HTM file association presence without recording handler values.' -Kind 'FileAssociationPresence' -IssueArea 'Default apps' -ActionType 'File association check' -Risk 'low' -Targets @('.htm') -Hours 24
