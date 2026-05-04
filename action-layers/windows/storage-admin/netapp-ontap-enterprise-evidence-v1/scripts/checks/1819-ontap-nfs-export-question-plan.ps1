$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 1819 -ActionId 'STORAGE_NETAPP_ONTAP_NFS_EXPORT_QUESTION_PLAN_V1' -Title 'ONTAP NFS Export Question Plan' -LayerId 'netapp-ontap-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'netapp-ontap-enterprise-evidence-v1'