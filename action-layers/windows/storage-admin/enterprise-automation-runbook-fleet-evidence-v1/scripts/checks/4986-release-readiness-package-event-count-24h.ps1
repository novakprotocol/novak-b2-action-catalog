$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4986 -ActionId 'STORAGE_ENTERPRISE_AUTOMATION_RUNBOOK_FLEET_EVIDENCE_V1_RELEASE_READINESS_PACKAGE_EVENT_COUNT_24H_V1' -Title 'Release Readiness Package Event Count 24h' -LayerId 'enterprise-automation-runbook-fleet-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-automation-runbook-fleet-evidence-v1'