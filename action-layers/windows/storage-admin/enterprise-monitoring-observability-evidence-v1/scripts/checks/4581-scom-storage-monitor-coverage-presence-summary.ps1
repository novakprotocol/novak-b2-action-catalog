$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4581 -ActionId 'STORAGE_ENTERPRISE_MONITORING_OBSERVABILITY_EVIDENCE_V1_SCOM_STORAGE_MONITOR_COVERAGE_PRESENCE_SUMMARY_V1' -Title 'Scom Storage Monitor Coverage Presence Summary' -LayerId 'enterprise-monitoring-observability-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-monitoring-observability-evidence-v1'