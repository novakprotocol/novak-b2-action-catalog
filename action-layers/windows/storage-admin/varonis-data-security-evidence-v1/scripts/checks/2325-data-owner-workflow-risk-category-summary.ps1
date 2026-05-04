$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2325 -ActionId 'STORAGE_VARONIS_DATA_OWNER_WORKFLOW_RISK_CATEGORY_SUMMARY_V1' -Title 'Data Owner Workflow Risk Category Summary' -LayerId 'varonis-data-security-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'varonis-data-security-evidence-v1'