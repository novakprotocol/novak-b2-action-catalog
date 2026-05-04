$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3586 -ActionId 'STORAGE_ENTERPRISE_SAN_FABRIC_EVIDENCE_V1_FLOGI_DATABASE_HOST_PRESENCE_EVENT_COUNT_24H_V1' -Title 'Flogi Database Host Presence Event Count 24h' -LayerId 'enterprise-san-fabric-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-san-fabric-evidence-v1'