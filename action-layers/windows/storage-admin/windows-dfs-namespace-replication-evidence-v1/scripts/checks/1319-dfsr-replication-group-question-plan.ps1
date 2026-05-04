$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 1319 -ActionId 'STORAGE_DFS_DFSR_REPLICATION_GROUP_QUESTION_PLAN_V1' -Title 'Dfsr Replication Group Question Plan' -LayerId 'windows-dfs-namespace-replication-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'windows-dfs-namespace-replication-evidence-v1'