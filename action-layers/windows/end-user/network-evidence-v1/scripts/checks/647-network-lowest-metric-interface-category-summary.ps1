#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_LOWEST_METRIC_INTERFACE_CATEGORY_SUMMARY_V1' -Slug 'network-lowest-metric-interface-category-summary' -Profile 'route' -Title 'Network lowest metric interface category summary'