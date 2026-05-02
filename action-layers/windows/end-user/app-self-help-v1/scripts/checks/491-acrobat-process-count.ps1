$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_ACROBAT_PROCESS_COUNT_V1' -Name 'Acrobat process count' -Description 'Counts Acrobat processes without reading PDFs.' -Kind 'ProcessCount' -IssueArea 'Adobe Acrobat' -ActionType 'App self-help check' -Risk 'low' -Targets @('Acrobat') -Hours 24
