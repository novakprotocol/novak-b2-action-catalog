$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3770 -ActionId 'STORAGE_ENTERPRISE_VIRTUALIZATION_STORAGE_EVIDENCE_V1_VMFS_CAPACITY_POSTURE_RUNNER_SUMMARY_V1' -Title 'Vmfs Capacity Posture Runner Summary' -LayerId 'enterprise-virtualization-storage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-virtualization-storage-evidence-v1'