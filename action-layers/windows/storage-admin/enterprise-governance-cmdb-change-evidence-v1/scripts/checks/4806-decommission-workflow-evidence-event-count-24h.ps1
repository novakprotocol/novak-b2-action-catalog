$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4806 -ActionId 'STORAGE_ENTERPRISE_GOVERNANCE_CMDB_CHANGE_EVIDENCE_V1_DECOMMISSION_WORKFLOW_EVIDENCE_EVENT_COUNT_24H_V1' -Title 'Decommission Workflow Evidence Event Count 24h' -LayerId 'enterprise-governance-cmdb-change-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-governance-cmdb-change-evidence-v1'