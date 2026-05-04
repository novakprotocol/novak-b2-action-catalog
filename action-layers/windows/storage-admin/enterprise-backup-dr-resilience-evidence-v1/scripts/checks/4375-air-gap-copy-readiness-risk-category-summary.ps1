$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4375 -ActionId 'STORAGE_ENTERPRISE_BACKUP_DR_RESILIENCE_EVIDENCE_V1_AIR_GAP_COPY_READINESS_RISK_CATEGORY_SUMMARY_V1' -Title 'Air Gap Copy Readiness Risk Category Summary' -LayerId 'enterprise-backup-dr-resilience-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-backup-dr-resilience-evidence-v1'