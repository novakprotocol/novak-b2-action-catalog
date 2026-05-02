$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_TEAMS_APPX_PACKAGE_COUNT_V1' -Name 'Teams Appx package count' -Description 'Counts user-visible Teams Appx packages without reading account data.' -Kind 'AppxPackageCount' -IssueArea 'Teams' -ActionType 'App self-help check' -Risk 'low' -Targets @('MSTeams*', 'MicrosoftTeams*') -Hours 24
