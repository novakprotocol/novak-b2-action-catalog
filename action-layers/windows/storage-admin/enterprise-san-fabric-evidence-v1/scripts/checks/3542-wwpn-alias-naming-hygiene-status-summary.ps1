$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3542 -ActionId 'STORAGE_ENTERPRISE_SAN_FABRIC_EVIDENCE_V1_WWPN_ALIAS_NAMING_HYGIENE_STATUS_SUMMARY_V1' -Title 'Wwpn Alias Naming Hygiene Status Summary' -LayerId 'enterprise-san-fabric-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-san-fabric-evidence-v1'