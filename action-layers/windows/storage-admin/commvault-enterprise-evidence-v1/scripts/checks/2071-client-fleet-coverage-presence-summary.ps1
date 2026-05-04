$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2071 -ActionId 'STORAGE_COMMVAULT_CLIENT_FLEET_COVERAGE_PRESENCE_SUMMARY_V1' -Title 'Client Fleet Coverage Presence Summary' -LayerId 'commvault-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'commvault-enterprise-evidence-v1'