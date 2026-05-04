$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 1846 -ActionId 'STORAGE_NETAPP_ONTAP_SNAPSHOT_SCHEDULE_EVENT_COUNT_24H_V1' -Title 'ONTAP Snapshot Schedule Event Count 24h' -LayerId 'netapp-ontap-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'netapp-ontap-enterprise-evidence-v1'