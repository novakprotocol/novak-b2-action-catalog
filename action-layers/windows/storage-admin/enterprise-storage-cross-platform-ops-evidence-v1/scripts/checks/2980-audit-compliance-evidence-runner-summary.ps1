$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2980 -ActionId 'STORAGE_ENTERPRISE_AUDIT_COMPLIANCE_EVIDENCE_RUNNER_SUMMARY_V1' -Title 'Audit Compliance Evidence Runner Summary' -LayerId 'enterprise-storage-cross-platform-ops-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-storage-cross-platform-ops-evidence-v1'