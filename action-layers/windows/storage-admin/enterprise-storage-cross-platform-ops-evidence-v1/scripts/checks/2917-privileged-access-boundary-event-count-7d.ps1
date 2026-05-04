$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2917 -ActionId 'STORAGE_ENTERPRISE_PRIVILEGED_ACCESS_BOUNDARY_EVENT_COUNT_7D_V1' -Title 'Privileged Access Boundary Event Count 7d' -LayerId 'enterprise-storage-cross-platform-ops-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-storage-cross-platform-ops-evidence-v1'