$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OUTLOOK_MAILTO_ASSOC_PRESENCE_V1' -Name 'MAILTO association presence' -Description 'Checks mailto association presence without recording handler values.' -Kind 'RegistryPresence' -IssueArea 'Outlook' -ActionType 'File association check' -Risk 'low' -Targets @('HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\mailto\UserChoice') -Hours 24
