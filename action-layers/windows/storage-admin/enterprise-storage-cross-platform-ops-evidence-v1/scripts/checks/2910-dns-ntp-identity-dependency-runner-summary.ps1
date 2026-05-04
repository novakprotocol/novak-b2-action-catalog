$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2910 -ActionId 'STORAGE_ENTERPRISE_DNS_NTP_IDENTITY_DEPENDENCY_RUNNER_SUMMARY_V1' -Title 'DNS NTP Identity Dependency Runner Summary' -LayerId 'enterprise-storage-cross-platform-ops-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-storage-cross-platform-ops-evidence-v1'