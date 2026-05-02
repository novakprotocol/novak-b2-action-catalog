$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OUTLOOK_PROFILE_REG_PRESENCE_V1' -Name 'Outlook profile registry presence' -Description 'Checks Outlook profile key presence without recording profile names or values.' -Kind 'RegistryPresence' -IssueArea 'Outlook' -ActionType 'Registry presence' -Risk 'low' -Targets @('HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles') -Hours 24
