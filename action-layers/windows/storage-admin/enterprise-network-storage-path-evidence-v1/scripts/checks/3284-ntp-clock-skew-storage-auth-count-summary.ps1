$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3284 -ActionId 'STORAGE_ENTERPRISE_NETWORK_STORAGE_PATH_EVIDENCE_V1_NTP_CLOCK_SKEW_STORAGE_AUTH_COUNT_SUMMARY_V1' -Title 'Ntp Clock Skew Storage Auth Count Summary' -LayerId 'enterprise-network-storage-path-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-network-storage-path-evidence-v1'