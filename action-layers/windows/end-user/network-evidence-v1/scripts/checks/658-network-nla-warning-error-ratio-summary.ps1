#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_NLA_WARNING_ERROR_RATIO_SUMMARY_V1' -Slug 'network-nla-warning-error-ratio-summary' -Profile 'profile' -Title 'Network NLA warning error ratio summary'