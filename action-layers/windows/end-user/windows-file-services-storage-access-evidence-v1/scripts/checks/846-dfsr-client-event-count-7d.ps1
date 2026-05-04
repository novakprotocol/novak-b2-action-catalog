$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 846 -ActionId 'ENDUSER_DFSR_CLIENT_EVENT_COUNT_7D_V1' -Title 'Dfsr Client Event Count 7d' -LayerId 'windows-file-services-storage-access-evidence-v1' -Audience 'end-user' -Tier 'Level 1' -IssueArea 'windows-file-services-storage-access-evidence-v1'