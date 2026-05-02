$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_OFFICE_APPX_PACKAGE_COUNT_V2' -Name 'Office Appx package count' -Description 'Counts user-visible Microsoft Office Appx packages without listing account data.' -Kind 'AppxPackageCount' -IssueArea 'Office' -ActionType 'App self-help check' -Risk 'low' -Targets @('Microsoft.Office*') -Hours 24
