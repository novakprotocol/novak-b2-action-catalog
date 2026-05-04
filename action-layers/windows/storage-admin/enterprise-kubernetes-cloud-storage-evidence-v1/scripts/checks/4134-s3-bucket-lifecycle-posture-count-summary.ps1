$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4134 -ActionId 'STORAGE_ENTERPRISE_KUBERNETES_CLOUD_STORAGE_EVIDENCE_V1_S3_BUCKET_LIFECYCLE_POSTURE_COUNT_SUMMARY_V1' -Title 'S3 Bucket Lifecycle Posture Count Summary' -LayerId 'enterprise-kubernetes-cloud-storage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-kubernetes-cloud-storage-evidence-v1'