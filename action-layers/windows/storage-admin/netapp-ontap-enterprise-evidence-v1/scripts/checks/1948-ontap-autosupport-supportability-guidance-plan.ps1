$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 1948 -ActionId 'STORAGE_NETAPP_ONTAP_AUTOSUPPORT_SUPPORTABILITY_GUIDANCE_PLAN_V1' -Title 'ONTAP AutoSupport Supportability Guidance Plan' -LayerId 'netapp-ontap-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'netapp-ontap-enterprise-evidence-v1'