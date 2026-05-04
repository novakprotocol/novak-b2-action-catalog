$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2496 -ActionId 'STORAGE_PURE_SUPPORT_BUNDLE_READINESS_EVENT_COUNT_24H_V1' -Title 'Support Bundle Readiness Event Count 24h' -LayerId 'pure-storage-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'pure-storage-enterprise-evidence-v1'