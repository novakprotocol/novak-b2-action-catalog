$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 1344 -ActionId 'STORAGE_DFS_DFSR_STAGING_COUNT_SUMMARY_V1' -Title 'Dfsr Staging Count Summary' -LayerId 'windows-dfs-namespace-replication-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'windows-dfs-namespace-replication-evidence-v1'