$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2793 -ActionId 'STORAGE_LINUX_COMMVAULT_LINUX_AGENT_CONFIGURATION_SUMMARY_V1' -Title 'Commvault Linux Agent Configuration Summary' -LayerId 'linux-storage-host-fleet-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'linux-storage-host-fleet-evidence-v1'