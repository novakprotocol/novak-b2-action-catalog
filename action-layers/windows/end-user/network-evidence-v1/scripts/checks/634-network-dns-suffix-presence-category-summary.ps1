#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_DNS_SUFFIX_PRESENCE_CATEGORY_SUMMARY_V1' -Slug 'network-dns-suffix-presence-category-summary' -Profile 'dns' -Title 'Network DNS suffix presence category summary'