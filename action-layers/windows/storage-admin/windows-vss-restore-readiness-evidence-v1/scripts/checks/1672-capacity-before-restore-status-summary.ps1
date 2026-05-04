$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 1672 -ActionId 'STORAGE_RESTORE_CAPACITY_BEFORE_RESTORE_STATUS_SUMMARY_V1' -Title 'Capacity Before Restore Status Summary' -LayerId 'windows-vss-restore-readiness-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'windows-vss-restore-readiness-evidence-v1'