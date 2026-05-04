$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4088 -ActionId 'STORAGE_ENTERPRISE_KUBERNETES_CLOUD_STORAGE_EVIDENCE_V1_CEPH_ROOK_CLUSTER_CAPACITY_GUIDANCE_PLAN_V1' -Title 'Ceph Rook Cluster Capacity Guidance Plan' -LayerId 'enterprise-kubernetes-cloud-storage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-kubernetes-cloud-storage-evidence-v1'