$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2698 -ActionId 'STORAGE_LINUX_LVM_VOLUME_GROUP_GUIDANCE_PLAN_V1' -Title 'LVM Volume Group Guidance Plan' -LayerId 'linux-storage-host-fleet-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'linux-storage-host-fleet-evidence-v1'