$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4628 -ActionId 'STORAGE_ENTERPRISE_MONITORING_OBSERVABILITY_EVIDENCE_V1_LATENCY_PERCENTILE_TREND_GUIDANCE_PLAN_V1' -Title 'Latency Percentile Trend Guidance Plan' -LayerId 'enterprise-monitoring-observability-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-monitoring-observability-evidence-v1'