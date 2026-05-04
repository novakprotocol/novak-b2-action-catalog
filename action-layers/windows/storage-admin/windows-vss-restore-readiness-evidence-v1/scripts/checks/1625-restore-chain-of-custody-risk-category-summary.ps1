$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 1625 -ActionId 'STORAGE_RESTORE_RESTORE_CHAIN_OF_CUSTODY_RISK_CATEGORY_SUMMARY_V1' -Title 'Restore Chain Of Custody Risk Category Summary' -LayerId 'windows-vss-restore-readiness-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'windows-vss-restore-readiness-evidence-v1'