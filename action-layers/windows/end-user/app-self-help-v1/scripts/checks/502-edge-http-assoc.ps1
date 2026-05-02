$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_EDGE_HTTP_ASSOC_PRESENCE_V1' -Name 'HTTP association presence' -Description 'Checks HTTP association presence without recording handler values.' -Kind 'RegistryPresence' -IssueArea 'Edge' -ActionType 'Registry presence' -Risk 'low' -Targets @('HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice') -Hours 24
