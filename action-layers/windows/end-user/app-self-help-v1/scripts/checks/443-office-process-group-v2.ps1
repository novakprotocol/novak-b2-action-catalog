$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OFFICE_PROCESS_GROUP_V2' -Name 'Office process group count' -Description 'Counts common Office application processes without reading documents.' -Kind 'ProcessCount' -IssueArea 'Office' -ActionType 'App self-help check' -Risk 'low' -Targets @('WINWORD', 'EXCEL', 'POWERPNT', 'ONENOTE', 'OUTLOOK', 'MSACCESS', 'MSPUB') -Hours 24
