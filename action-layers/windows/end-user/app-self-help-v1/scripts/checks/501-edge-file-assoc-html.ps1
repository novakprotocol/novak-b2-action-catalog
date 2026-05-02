$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_EDGE_FILE_ASSOC_HTML_V1' -Name 'HTML association presence' -Description 'Checks HTML association presence without recording handler values.' -Kind 'FileAssociationPresence' -IssueArea 'Edge' -ActionType 'File association check' -Risk 'low' -Targets @('.html') -Hours 24
