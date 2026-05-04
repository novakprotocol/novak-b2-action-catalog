$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4665 -ActionId 'STORAGE_ENTERPRISE_MONITORING_OBSERVABILITY_EVIDENCE_V1_ALERT_NOISE_SUPPRESSION_RISK_CATEGORY_SUMMARY_V1' -Title 'Alert Noise Suppression Risk Category Summary' -LayerId 'enterprise-monitoring-observability-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-monitoring-observability-evidence-v1'