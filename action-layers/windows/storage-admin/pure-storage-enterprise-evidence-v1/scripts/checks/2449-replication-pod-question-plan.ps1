$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2449 -ActionId 'STORAGE_PURE_REPLICATION_POD_QUESTION_PLAN_V1' -Title 'Replication Pod Question Plan' -LayerId 'pure-storage-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'pure-storage-enterprise-evidence-v1'