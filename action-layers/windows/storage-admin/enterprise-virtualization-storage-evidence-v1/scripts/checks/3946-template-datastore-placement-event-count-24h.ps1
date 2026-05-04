$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3946 -ActionId 'STORAGE_ENTERPRISE_VIRTUALIZATION_STORAGE_EVIDENCE_V1_TEMPLATE_DATASTORE_PLACEMENT_EVENT_COUNT_24H_V1' -Title 'Template Datastore Placement Event Count 24h' -LayerId 'enterprise-virtualization-storage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-virtualization-storage-evidence-v1'