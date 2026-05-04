$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2587 -ActionId 'STORAGE_UNITY_CIFS_SERVER_SHARE_EVENT_COUNT_7D_V1' -Title 'CIFS Server Share Event Count 7d' -LayerId 'dell-emc-unity-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'dell-emc-unity-enterprise-evidence-v1'