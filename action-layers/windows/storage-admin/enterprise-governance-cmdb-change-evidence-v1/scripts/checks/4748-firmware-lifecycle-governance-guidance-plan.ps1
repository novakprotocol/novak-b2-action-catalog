$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4748 -ActionId 'STORAGE_ENTERPRISE_GOVERNANCE_CMDB_CHANGE_EVIDENCE_V1_FIRMWARE_LIFECYCLE_GOVERNANCE_GUIDANCE_PLAN_V1' -Title 'Firmware Lifecycle Governance Guidance Plan' -LayerId 'enterprise-governance-cmdb-change-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-governance-cmdb-change-evidence-v1'