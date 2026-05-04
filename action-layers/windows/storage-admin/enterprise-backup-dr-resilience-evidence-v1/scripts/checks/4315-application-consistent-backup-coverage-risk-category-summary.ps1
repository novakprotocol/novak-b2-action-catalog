$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4315 -ActionId 'STORAGE_ENTERPRISE_BACKUP_DR_RESILIENCE_EVIDENCE_V1_APPLICATION_CONSISTENT_BACKUP_COVERAGE_RISK_CATEGORY_SUMMARY_V1' -Title 'Application Consistent Backup Coverage Risk Category Summary' -LayerId 'enterprise-backup-dr-resilience-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-backup-dr-resilience-evidence-v1'