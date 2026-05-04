$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4917 -ActionId 'STORAGE_ENTERPRISE_SECURITY_RANSOMWARE_STORAGE_EVIDENCE_V1_EXCESSIVE_PERMISSION_RISK_EVENT_COUNT_7D_V1' -Title 'Excessive Permission Risk Event Count 7d' -LayerId 'enterprise-security-ransomware-storage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-security-ransomware-storage-evidence-v1'