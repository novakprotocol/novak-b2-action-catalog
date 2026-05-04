$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3961 -ActionId 'STORAGE_ENTERPRISE_VIRTUALIZATION_STORAGE_EVIDENCE_V1_RESTORE_TARGET_DATASTORE_READINESS_PRESENCE_SUMMARY_V1' -Title 'Restore Target Datastore Readiness Presence Summary' -LayerId 'enterprise-virtualization-storage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-virtualization-storage-evidence-v1'