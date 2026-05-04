$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2108 -ActionId 'STORAGE_COMMVAULT_NAS_CLIENT_COVERAGE_GUIDANCE_PLAN_V1' -Title 'Nas Client Coverage Guidance Plan' -LayerId 'commvault-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'commvault-enterprise-evidence-v1'