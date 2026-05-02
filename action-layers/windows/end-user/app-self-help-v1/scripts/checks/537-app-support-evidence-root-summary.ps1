$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-AppSelfHelpV1.ps1"
. $LibPath

Invoke-AppSelfHelpAction -ActionId 'ENDUSER_APPSELFHELP_SUPPORT_EVIDENCE_ROOT_SUMMARY_V1' -Name 'Support evidence root summary' -Description 'Counts existing NOVAK B2 local evidence directories without listing names.' -Kind 'SupportEvidenceSummary' -IssueArea 'Support evidence' -ActionType 'Evidence summary' -Risk 'low' -Targets @() -Hours 24
