$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2111 -ActionId 'STORAGE_COMMVAULT_NETAPP_ARRAY_INTEGRATION_PRESENCE_SUMMARY_V1' -Title 'NetApp Array Integration Presence Summary' -LayerId 'commvault-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'commvault-enterprise-evidence-v1'