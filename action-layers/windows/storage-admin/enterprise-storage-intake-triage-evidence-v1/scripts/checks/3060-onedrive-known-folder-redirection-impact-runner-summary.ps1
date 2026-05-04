$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3060 -ActionId 'STORAGE_ENTERPRISE_STORAGE_INTAKE_TRIAGE_EVIDENCE_V1_ONEDRIVE_KNOWN_FOLDER_REDIRECTION_IMPACT_RUNNER_SUMMARY_V1' -Title 'Onedrive Known Folder Redirection Impact Runner Summary' -LayerId 'enterprise-storage-intake-triage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-storage-intake-triage-evidence-v1'