$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2364 -ActionId 'STORAGE_PURE_FLASHARRAY_POWERSHELL_SDK_COUNT_SUMMARY_V1' -Title 'FlashArray Powershell Sdk Count Summary' -LayerId 'pure-storage-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'pure-storage-enterprise-evidence-v1'