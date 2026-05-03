#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_PROFILE_IPV4_IPV6_CONNECTIVITY_SUMMARY_V1' -Slug 'network-profile-ipv4-ipv6-connectivity-summary' -Profile 'profile' -Title 'Network profile IPv4 IPv6 connectivity summary'