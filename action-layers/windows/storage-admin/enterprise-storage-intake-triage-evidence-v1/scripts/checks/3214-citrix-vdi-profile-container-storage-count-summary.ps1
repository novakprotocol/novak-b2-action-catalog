$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3214 -ActionId 'STORAGE_ENTERPRISE_STORAGE_INTAKE_TRIAGE_EVIDENCE_V1_CITRIX_VDI_PROFILE_CONTAINER_STORAGE_COUNT_SUMMARY_V1' -Title 'Citrix Vdi Profile Container Storage Count Summary' -LayerId 'enterprise-storage-intake-triage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-storage-intake-triage-evidence-v1'