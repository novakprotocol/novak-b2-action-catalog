$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2247 -ActionId 'STORAGE_VARONIS_PROBE_SERVICE_HEALTH_EVENT_COUNT_7D_V1' -Title 'Probe Service Health Event Count 7d' -LayerId 'varonis-data-security-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'varonis-data-security-evidence-v1'