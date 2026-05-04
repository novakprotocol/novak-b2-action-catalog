$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2290 -ActionId 'STORAGE_VARONIS_SENSITIVE_DATA_CLASSIFICATION_RUNNER_SUMMARY_V1' -Title 'Sensitive Data Classification Runner Summary' -LayerId 'varonis-data-security-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'varonis-data-security-evidence-v1'