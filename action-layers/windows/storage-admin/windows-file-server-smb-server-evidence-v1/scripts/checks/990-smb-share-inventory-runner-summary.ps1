$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 990 -ActionId 'STORAGE_SMB_SERVER_SMB_SHARE_INVENTORY_RUNNER_SUMMARY_V1' -Title 'Smb Share Inventory Runner Summary' -LayerId 'windows-file-server-smb-server-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'windows-file-server-smb-server-evidence-v1'