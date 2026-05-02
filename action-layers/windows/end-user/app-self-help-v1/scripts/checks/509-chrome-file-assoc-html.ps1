$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_CHROME_FILE_ASSOC_HTML_V1' -Name 'HTML association presence for browser review' -Description 'Checks HTML association presence without recording handler values.' -Kind 'FileAssociationPresence' -IssueArea 'Chrome' -ActionType 'File association check' -Risk 'low' -Targets @('.html') -Hours 24
