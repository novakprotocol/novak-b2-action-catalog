#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_DHCP_SERVICE_START_MODE_SUMMARY_V1' -Slug 'network-dhcp-service-start-mode-summary' -Profile 'dhcp' -Title 'Network DHCP service start mode summary'