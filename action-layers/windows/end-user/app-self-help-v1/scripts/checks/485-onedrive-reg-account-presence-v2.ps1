$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_ONEDRIVE_REG_ACCOUNT_PRESENCE_V2' -Name 'OneDrive account registry presence' -Description 'Checks OneDrive account registry presence without recording account names or values.' -Kind 'RegistryPresence' -IssueArea 'OneDrive' -ActionType 'Registry presence' -Risk 'low' -Targets @('HKCU:\Software\Microsoft\OneDrive\Accounts') -Hours 24
