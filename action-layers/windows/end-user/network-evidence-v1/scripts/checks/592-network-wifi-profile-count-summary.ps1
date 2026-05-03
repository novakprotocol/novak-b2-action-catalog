#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')

Invoke-NetworkEvidenceAction -ActionId 'ENDUSER_NETWORK_WIFI_PROFILE_COUNT_SUMMARY_V1' -Slug 'network-wifi-profile-count-summary'