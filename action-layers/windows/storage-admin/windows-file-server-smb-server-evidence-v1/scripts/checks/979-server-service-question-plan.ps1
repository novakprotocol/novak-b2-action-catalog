$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 979 -ActionId 'STORAGE_SMB_SERVER_SERVER_SERVICE_QUESTION_PLAN_V1' -Title 'Server Service Question Plan' -LayerId 'windows-file-server-smb-server-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'windows-file-server-smb-server-evidence-v1'