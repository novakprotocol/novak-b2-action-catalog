$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 3067 -ActionId 'STORAGE_ENTERPRISE_STORAGE_INTAKE_TRIAGE_EVIDENCE_V1_VPN_CLIENT_STORAGE_REACHABILITY_EVENT_COUNT_7D_V1' -Title 'Vpn Client Storage Reachability Event Count 7d' -LayerId 'enterprise-storage-intake-triage-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'enterprise-storage-intake-triage-evidence-v1'