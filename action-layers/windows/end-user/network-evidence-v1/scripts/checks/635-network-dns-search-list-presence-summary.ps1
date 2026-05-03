#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_DNS_SEARCH_LIST_PRESENCE_SUMMARY_V1' -Slug 'network-dns-search-list-presence-summary' -Profile 'dns' -Title 'Network DNS search list presence summary'