$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3637 -ActionId 'STORAGE_ENTERPRISE_SAN_FABRIC_EVIDENCE_V1_PORT_ERROR_COUNTER_TREND_EVENT_COUNT_7D_V1' -Title 'Port Error Counter Trend Event Count 7d' -LayerId 'enterprise-san-fabric-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-san-fabric-evidence-v1'