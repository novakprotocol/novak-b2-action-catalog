$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_EDGE_HTTPS_ASSOC_PRESENCE_V1' -Name 'HTTPS association presence' -Description 'Checks HTTPS association presence without recording handler values.' -Kind 'RegistryPresence' -IssueArea 'Edge' -ActionType 'Registry presence' -Risk 'low' -Targets @('HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice') -Hours 24
