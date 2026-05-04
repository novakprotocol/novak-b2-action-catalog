$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 1701 -ActionId 'STORAGE_NETAPP_ONTAP_PACKAGE_READINESS_PRESENCE_SUMMARY_V1' -Title 'ONTAP Package Readiness Presence Summary' -LayerId 'netapp-ontap-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'netapp-ontap-enterprise-evidence-v1'