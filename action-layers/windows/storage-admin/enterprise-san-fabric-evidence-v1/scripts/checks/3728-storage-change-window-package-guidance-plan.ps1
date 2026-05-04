$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3728 -ActionId 'STORAGE_ENTERPRISE_SAN_FABRIC_EVIDENCE_V1_STORAGE_CHANGE_WINDOW_PACKAGE_GUIDANCE_PLAN_V1' -Title 'Storage Change Window Package Guidance Plan' -LayerId 'enterprise-san-fabric-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-san-fabric-evidence-v1'