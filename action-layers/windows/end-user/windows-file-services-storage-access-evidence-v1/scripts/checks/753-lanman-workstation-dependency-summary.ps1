$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 753 -ActionId 'ENDUSER_LANMAN_WORKSTATION_DEPENDENCY_SUMMARY_V1' -Title 'Lanman Workstation Dependency Summary' -LayerId 'windows-file-services-storage-access-evidence-v1' -Audience 'end-user' -Tier 'Level 1' -IssueArea 'windows-file-services-storage-access-evidence-v1'