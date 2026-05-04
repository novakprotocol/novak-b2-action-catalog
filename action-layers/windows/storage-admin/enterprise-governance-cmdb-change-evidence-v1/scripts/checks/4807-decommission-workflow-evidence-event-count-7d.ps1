$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4807 -ActionId 'STORAGE_ENTERPRISE_GOVERNANCE_CMDB_CHANGE_EVIDENCE_V1_DECOMMISSION_WORKFLOW_EVIDENCE_EVENT_COUNT_7D_V1' -Title 'Decommission Workflow Evidence Event Count 7d' -LayerId 'enterprise-governance-cmdb-change-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-governance-cmdb-change-evidence-v1'