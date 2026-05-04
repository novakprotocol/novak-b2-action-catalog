$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2572 -ActionId 'STORAGE_UNITY_NAS_SERVER_HEALTH_STATUS_SUMMARY_V1' -Title 'Nas Server Health Status Summary' -LayerId 'dell-emc-unity-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'dell-emc-unity-enterprise-evidence-v1'