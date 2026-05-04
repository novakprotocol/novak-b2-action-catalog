$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3291 -ActionId 'STORAGE_ENTERPRISE_NETWORK_STORAGE_PATH_EVIDENCE_V1_ACTIVE_DIRECTORY_SITE_SUBNET_MAPPING_PRESENCE_SUMMARY_V1' -Title 'Active Directory Site Subnet Mapping Presence Summary' -LayerId 'enterprise-network-storage-path-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-network-storage-path-evidence-v1'