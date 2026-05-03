#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_INTERFACE_ADDRESS_COUNT_CATEGORY_SUMMARY_V1' -Slug 'network-interface-address-count-category-summary' -Profile 'ip' -Title 'Network interface address count category summary'