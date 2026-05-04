$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3308 -ActionId 'STORAGE_ENTERPRISE_NETWORK_STORAGE_PATH_EVIDENCE_V1_LDAP_GLOBAL_CATALOG_REACHABILITY_GUIDANCE_PLAN_V1' -Title 'Ldap Global Catalog Reachability Guidance Plan' -LayerId 'enterprise-network-storage-path-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-network-storage-path-evidence-v1'