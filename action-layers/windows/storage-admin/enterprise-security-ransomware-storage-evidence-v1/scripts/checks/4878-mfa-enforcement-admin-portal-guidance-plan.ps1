$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 4878 -ActionId 'STORAGE_ENTERPRISE_SECURITY_RANSOMWARE_STORAGE_EVIDENCE_V1_MFA_ENFORCEMENT_ADMIN_PORTAL_GUIDANCE_PLAN_V1' -Title 'Mfa Enforcement Admin Portal Guidance Plan' -LayerId 'enterprise-security-ransomware-storage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-security-ransomware-storage-evidence-v1'