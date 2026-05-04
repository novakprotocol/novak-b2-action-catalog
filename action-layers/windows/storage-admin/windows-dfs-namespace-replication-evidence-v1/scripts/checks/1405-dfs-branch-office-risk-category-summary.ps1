$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 1405 -ActionId 'STORAGE_DFS_DFS_BRANCH_OFFICE_RISK_CATEGORY_SUMMARY_V1' -Title 'Dfs Branch Office Risk Category Summary' -LayerId 'windows-dfs-namespace-replication-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'windows-dfs-namespace-replication-evidence-v1'