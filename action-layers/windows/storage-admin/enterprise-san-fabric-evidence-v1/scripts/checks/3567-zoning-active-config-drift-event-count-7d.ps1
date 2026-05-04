$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3567 -ActionId 'STORAGE_ENTERPRISE_SAN_FABRIC_EVIDENCE_V1_ZONING_ACTIVE_CONFIG_DRIFT_EVENT_COUNT_7D_V1' -Title 'Zoning Active Config Drift Event Count 7d' -LayerId 'enterprise-san-fabric-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-san-fabric-evidence-v1'