$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 1981 -ActionId 'STORAGE_COMMVAULT_COMMSERVE_SERVICE_HEALTH_PRESENCE_SUMMARY_V1' -Title 'CommServe Service Health Presence Summary' -LayerId 'commvault-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'commvault-enterprise-evidence-v1'