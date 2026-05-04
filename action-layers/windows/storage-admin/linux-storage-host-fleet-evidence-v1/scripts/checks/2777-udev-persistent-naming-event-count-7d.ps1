$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2777 -ActionId 'STORAGE_LINUX_UDEV_PERSISTENT_NAMING_EVENT_COUNT_7D_V1' -Title 'udev Persistent Naming Event Count 7d' -LayerId 'linux-storage-host-fleet-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'linux-storage-host-fleet-evidence-v1'