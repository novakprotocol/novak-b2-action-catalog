$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_DEFAULT_PRINTER_PRESENCE_V2' -Name 'Default printer presence' -Description 'Checks default printer presence without recording printer names.' -Kind 'RegistryPresence' -IssueArea 'Printers' -ActionType 'Registry presence' -Risk 'low' -Targets @('HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows') -Hours 24
