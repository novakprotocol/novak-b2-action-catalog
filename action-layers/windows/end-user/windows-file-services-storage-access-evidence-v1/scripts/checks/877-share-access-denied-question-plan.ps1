$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 877 -ActionId 'ENDUSER_SHARE_ACCESS_DENIED_QUESTION_PLAN_V1' -Title 'Share Access Denied Question Plan' -LayerId 'windows-file-services-storage-access-evidence-v1' -Audience 'end-user' -Tier 'Level 1' -IssueArea 'windows-file-services-storage-access-evidence-v1'