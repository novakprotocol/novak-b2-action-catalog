#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_ADAPTER_ADMIN_OPERATIONAL_STATE_SUMMARY_V1' -Slug 'network-adapter-admin-operational-state-summary' -Profile 'adapter' -Title 'Network adapter admin operational state summary'