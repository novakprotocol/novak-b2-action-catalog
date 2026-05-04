$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3317 -ActionId 'STORAGE_ENTERPRISE_NETWORK_STORAGE_PATH_EVIDENCE_V1_KERBEROS_KDC_REACHABILITY_EVENT_COUNT_7D_V1' -Title 'Kerberos Kdc Reachability Event Count 7d' -LayerId 'enterprise-network-storage-path-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-network-storage-path-evidence-v1'