#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_FIREWALL_BLOCK_ALLOW_BALANCE_SUMMARY_V1' -Slug 'network-firewall-block-allow-balance-summary' -Profile 'firewall' -Title 'Network firewall block allow balance summary'