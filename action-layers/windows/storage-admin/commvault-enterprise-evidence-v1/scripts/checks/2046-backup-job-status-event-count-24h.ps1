$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2046 -ActionId 'STORAGE_COMMVAULT_BACKUP_JOB_STATUS_EVENT_COUNT_24H_V1' -Title 'Backup Job Status Event Count 24h' -LayerId 'commvault-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'commvault-enterprise-evidence-v1'