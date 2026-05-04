$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2707 -ActionId 'STORAGE_LINUX_FILESYSTEM_MOUNT_HEALTH_EVENT_COUNT_7D_V1' -Title 'Filesystem Mount Health Event Count 7d' -LayerId 'linux-storage-host-fleet-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'linux-storage-host-fleet-evidence-v1'