#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_PROFILE_PUBLIC_PRIVATE_DOMAIN_CATEGORY_SUMMARY_V1' -Slug 'network-profile-public-private-domain-category-summary' -Profile 'profile' -Title 'Network profile public private domain category summary'