$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4647 -ActionId 'STORAGE_ENTERPRISE_MONITORING_OBSERVABILITY_EVIDENCE_V1_CACHE_HIT_RATIO_POSTURE_EVENT_COUNT_7D_V1' -Title 'Cache Hit Ratio Posture Event Count 7d' -LayerId 'enterprise-monitoring-observability-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-monitoring-observability-evidence-v1'