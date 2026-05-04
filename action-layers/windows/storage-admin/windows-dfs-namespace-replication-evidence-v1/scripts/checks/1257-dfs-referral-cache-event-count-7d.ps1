$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 1257 -ActionId 'STORAGE_DFS_DFS_REFERRAL_CACHE_EVENT_COUNT_7D_V1' -Title 'Dfs Referral Cache Event Count 7d' -LayerId 'windows-dfs-namespace-replication-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'windows-dfs-namespace-replication-evidence-v1'