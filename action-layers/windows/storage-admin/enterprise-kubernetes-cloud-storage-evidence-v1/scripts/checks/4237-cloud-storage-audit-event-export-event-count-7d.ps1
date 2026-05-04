$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4237 -ActionId 'STORAGE_ENTERPRISE_KUBERNETES_CLOUD_STORAGE_EVIDENCE_V1_CLOUD_STORAGE_AUDIT_EVENT_EXPORT_EVENT_COUNT_7D_V1' -Title 'Cloud Storage Audit Event Export Event Count 7d' -LayerId 'enterprise-kubernetes-cloud-storage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-kubernetes-cloud-storage-evidence-v1'