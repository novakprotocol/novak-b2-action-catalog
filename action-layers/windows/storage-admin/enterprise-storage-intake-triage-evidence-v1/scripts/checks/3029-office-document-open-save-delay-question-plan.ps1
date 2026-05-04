$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3029 -ActionId 'STORAGE_ENTERPRISE_STORAGE_INTAKE_TRIAGE_EVIDENCE_V1_OFFICE_DOCUMENT_OPEN_SAVE_DELAY_QUESTION_PLAN_V1' -Title 'Office Document Open Save Delay Question Plan' -LayerId 'enterprise-storage-intake-triage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-storage-intake-triage-evidence-v1'