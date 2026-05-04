$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3657 -ActionId 'STORAGE_ENTERPRISE_SAN_FABRIC_EVIDENCE_V1_LINK_SPEED_MISMATCH_EVENT_COUNT_7D_V1' -Title 'Link Speed Mismatch Event Count 7d' -LayerId 'enterprise-san-fabric-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-san-fabric-evidence-v1'