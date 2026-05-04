$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 1114 -ActionId 'STORAGE_SMB_SERVER_SMB_ACCESS_DENIED_COUNT_SUMMARY_V1' -Title 'Smb Access Denied Count Summary' -LayerId 'windows-file-server-smb-server-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'windows-file-server-smb-server-evidence-v1'