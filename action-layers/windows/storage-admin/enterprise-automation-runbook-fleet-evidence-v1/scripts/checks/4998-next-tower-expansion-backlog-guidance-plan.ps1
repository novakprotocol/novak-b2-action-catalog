$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4998 -ActionId 'STORAGE_ENTERPRISE_AUTOMATION_RUNBOOK_FLEET_EVIDENCE_V1_NEXT_TOWER_EXPANSION_BACKLOG_GUIDANCE_PLAN_V1' -Title 'Next Tower Expansion Backlog Guidance Plan' -LayerId 'enterprise-automation-runbook-fleet-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-automation-runbook-fleet-evidence-v1'