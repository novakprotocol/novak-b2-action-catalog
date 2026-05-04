$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4126 -ActionId 'STORAGE_ENTERPRISE_KUBERNETES_CLOUD_STORAGE_EVIDENCE_V1_CLOUD_FILE_SHARE_MOUNT_HEALTH_EVENT_COUNT_24H_V1' -Title 'Cloud File Share Mount Health Event Count 24h' -LayerId 'enterprise-kubernetes-cloud-storage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-kubernetes-cloud-storage-evidence-v1'