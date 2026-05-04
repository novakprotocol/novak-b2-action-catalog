$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 980 -ActionId 'STORAGE_SMB_SERVER_SERVER_SERVICE_RUNNER_SUMMARY_V1' -Title 'Server Service Runner Summary' -LayerId 'windows-file-server-smb-server-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'windows-file-server-smb-server-evidence-v1'