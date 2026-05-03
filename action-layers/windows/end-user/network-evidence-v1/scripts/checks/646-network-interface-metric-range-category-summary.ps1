#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_INTERFACE_METRIC_RANGE_CATEGORY_SUMMARY_V1' -Slug 'network-interface-metric-range-category-summary' -Profile 'route' -Title 'Network interface metric range category summary'