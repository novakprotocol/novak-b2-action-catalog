$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2469 -ActionId 'STORAGE_PURE_CERTIFICATE_SUPPORTABILITY_QUESTION_PLAN_V1' -Title 'Certificate Supportability Question Plan' -LayerId 'pure-storage-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'pure-storage-enterprise-evidence-v1'