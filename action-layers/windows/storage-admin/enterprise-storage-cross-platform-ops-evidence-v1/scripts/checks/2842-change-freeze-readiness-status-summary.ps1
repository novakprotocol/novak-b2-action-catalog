$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2842 -ActionId 'STORAGE_ENTERPRISE_CHANGE_FREEZE_READINESS_STATUS_SUMMARY_V1' -Title 'Change Freeze Readiness Status Summary' -LayerId 'enterprise-storage-cross-platform-ops-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-storage-cross-platform-ops-evidence-v1'