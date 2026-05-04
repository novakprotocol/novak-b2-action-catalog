$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 1534 -ActionId 'STORAGE_RESTORE_FOLDER_RESTORE_REQUEST_COUNT_SUMMARY_V1' -Title 'Folder Restore Request Count Summary' -LayerId 'windows-vss-restore-readiness-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'windows-vss-restore-readiness-evidence-v1'