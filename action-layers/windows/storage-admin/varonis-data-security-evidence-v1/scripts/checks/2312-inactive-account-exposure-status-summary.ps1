$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2312 -ActionId 'STORAGE_VARONIS_INACTIVE_ACCOUNT_EXPOSURE_STATUS_SUMMARY_V1' -Title 'Inactive Account Exposure Status Summary' -LayerId 'varonis-data-security-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'varonis-data-security-evidence-v1'