$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 1636 -ActionId 'STORAGE_RESTORE_RESTORE_TEST_EVIDENCE_EVENT_COUNT_24H_V1' -Title 'Restore Test Evidence Event Count 24h' -LayerId 'windows-vss-restore-readiness-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'windows-vss-restore-readiness-evidence-v1'