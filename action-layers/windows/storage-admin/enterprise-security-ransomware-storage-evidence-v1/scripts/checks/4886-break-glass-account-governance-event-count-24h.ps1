$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4886 -ActionId 'STORAGE_ENTERPRISE_SECURITY_RANSOMWARE_STORAGE_EVIDENCE_V1_BREAK_GLASS_ACCOUNT_GOVERNANCE_EVENT_COUNT_24H_V1' -Title 'Break Glass Account Governance Event Count 24h' -LayerId 'enterprise-security-ransomware-storage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-security-ransomware-storage-evidence-v1'