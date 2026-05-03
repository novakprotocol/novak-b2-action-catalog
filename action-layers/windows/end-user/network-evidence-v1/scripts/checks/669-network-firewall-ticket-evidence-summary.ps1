#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_FIREWALL_TICKET_EVIDENCE_SUMMARY_V1' -Slug 'network-firewall-ticket-evidence-summary' -Profile 'firewall' -Title 'Network firewall ticket evidence summary'