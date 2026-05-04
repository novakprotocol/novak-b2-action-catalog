$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3787 -ActionId 'STORAGE_ENTERPRISE_VIRTUALIZATION_STORAGE_EVIDENCE_V1_VVOL_PROVIDER_REGISTRATION_EVENT_COUNT_7D_V1' -Title 'Vvol Provider Registration Event Count 7d' -LayerId 'enterprise-virtualization-storage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-virtualization-storage-evidence-v1'