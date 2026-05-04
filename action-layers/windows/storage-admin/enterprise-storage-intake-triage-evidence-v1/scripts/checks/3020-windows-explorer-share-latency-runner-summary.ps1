$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3020 -ActionId 'STORAGE_ENTERPRISE_STORAGE_INTAKE_TRIAGE_EVIDENCE_V1_WINDOWS_EXPLORER_SHARE_LATENCY_RUNNER_SUMMARY_V1' -Title 'Windows Explorer Share Latency Runner Summary' -LayerId 'enterprise-storage-intake-triage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-storage-intake-triage-evidence-v1'