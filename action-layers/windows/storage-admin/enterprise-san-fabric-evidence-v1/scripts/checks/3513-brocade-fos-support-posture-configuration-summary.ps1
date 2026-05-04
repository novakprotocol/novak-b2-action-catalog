$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3513 -ActionId 'STORAGE_ENTERPRISE_SAN_FABRIC_EVIDENCE_V1_BROCADE_FOS_SUPPORT_POSTURE_CONFIGURATION_SUMMARY_V1' -Title 'Brocade Fos Support Posture Configuration Summary' -LayerId 'enterprise-san-fabric-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-san-fabric-evidence-v1'