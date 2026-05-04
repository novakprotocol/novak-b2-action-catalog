$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3606 -ActionId 'STORAGE_ENTERPRISE_SAN_FABRIC_EVIDENCE_V1_NPIV_VIRTUAL_WWPN_COVERAGE_EVENT_COUNT_24H_V1' -Title 'Npiv Virtual Wwpn Coverage Event Count 24h' -LayerId 'enterprise-san-fabric-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-san-fabric-evidence-v1'