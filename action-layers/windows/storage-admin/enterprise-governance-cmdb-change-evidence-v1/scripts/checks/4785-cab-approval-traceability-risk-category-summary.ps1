$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4785 -ActionId 'STORAGE_ENTERPRISE_GOVERNANCE_CMDB_CHANGE_EVIDENCE_V1_CAB_APPROVAL_TRACEABILITY_RISK_CATEGORY_SUMMARY_V1' -Title 'Cab Approval Traceability Risk Category Summary' -LayerId 'enterprise-governance-cmdb-change-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-governance-cmdb-change-evidence-v1'