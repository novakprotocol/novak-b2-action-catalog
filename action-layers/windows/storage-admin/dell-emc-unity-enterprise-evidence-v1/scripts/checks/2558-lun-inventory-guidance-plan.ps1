$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path (Split-Path -Parent $Here) 'lib\Common-StorageEvidence.ps1')
Write-SafeActionResult -Number 2558 -ActionId 'STORAGE_UNITY_LUN_INVENTORY_GUIDANCE_PLAN_V1' -Title 'LUN Inventory Guidance Plan' -LayerId 'dell-emc-unity-enterprise-evidence-v1' -Audience 'storage-admin' -Tier 'Level 3' -IssueArea 'dell-emc-unity-enterprise-evidence-v1'