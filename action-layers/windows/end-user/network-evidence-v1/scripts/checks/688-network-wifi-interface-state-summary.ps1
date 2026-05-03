#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_WIFI_INTERFACE_STATE_SUMMARY_V1' -Slug 'network-wifi-interface-state-summary' -Profile 'wifi' -Title 'Network Wi-Fi interface state summary'