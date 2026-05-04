$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4957 -ActionId 'STORAGE_ENTERPRISE_AUTOMATION_RUNBOOK_FLEET_EVIDENCE_V1_AUTOMATION_RUNNER_HEALTH_EVENT_COUNT_7D_V1' -Title 'Automation Runner Health Event Count 7d' -LayerId 'enterprise-automation-runbook-fleet-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-automation-runbook-fleet-evidence-v1'