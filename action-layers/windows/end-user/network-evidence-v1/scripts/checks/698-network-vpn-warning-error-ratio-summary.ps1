#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_VPN_WARNING_ERROR_RATIO_SUMMARY_V1' -Slug 'network-vpn-warning-error-ratio-summary' -Profile 'vpn' -Title 'Network VPN warning error ratio summary'