$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4110 -ActionId 'STORAGE_ENTERPRISE_KUBERNETES_CLOUD_STORAGE_EVIDENCE_V1_ISCSI_CSI_SESSION_PATH_RUNNER_SUMMARY_V1' -Title 'Iscsi Csi Session Path Runner Summary' -LayerId 'enterprise-kubernetes-cloud-storage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-kubernetes-cloud-storage-evidence-v1'