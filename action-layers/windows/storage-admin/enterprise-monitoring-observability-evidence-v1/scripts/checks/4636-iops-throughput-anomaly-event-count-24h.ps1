$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4636 -ActionId 'STORAGE_ENTERPRISE_MONITORING_OBSERVABILITY_EVIDENCE_V1_IOPS_THROUGHPUT_ANOMALY_EVENT_COUNT_24H_V1' -Title 'Iops Throughput Anomaly Event Count 24h' -LayerId 'enterprise-monitoring-observability-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-monitoring-observability-evidence-v1'