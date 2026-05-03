#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_DHCP_RENEWAL_TIME_CATEGORY_SUMMARY_V1' -Slug 'network-dhcp-renewal-time-category-summary' -Profile 'dhcp' -Title 'Network DHCP renewal time category summary'