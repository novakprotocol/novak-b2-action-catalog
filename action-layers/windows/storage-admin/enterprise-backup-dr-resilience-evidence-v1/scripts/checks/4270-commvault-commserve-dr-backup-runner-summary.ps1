$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4270 -ActionId 'STORAGE_ENTERPRISE_BACKUP_DR_RESILIENCE_EVIDENCE_V1_COMMVAULT_COMMSERVE_DR_BACKUP_RUNNER_SUMMARY_V1' -Title 'Commvault Commserve Dr Backup Runner Summary' -LayerId 'enterprise-backup-dr-resilience-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-backup-dr-resilience-evidence-v1'