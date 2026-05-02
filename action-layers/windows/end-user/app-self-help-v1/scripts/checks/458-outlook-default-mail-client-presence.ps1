$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OUTLOOK_DEFAULT_MAIL_CLIENT_PRESENCE_V1' -Name 'Default mail client registry presence' -Description 'Checks default mail client registry presence without recording values.' -Kind 'RegistryPresence' -IssueArea 'Outlook' -ActionType 'Registry presence' -Risk 'low' -Targets @('HKCU:\Software\Clients\Mail') -Hours 24
