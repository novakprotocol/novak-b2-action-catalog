# ENDUSER_GET_LOCAL_DRIVE_SPACE_V1
# NOenterpriseK B2 Windows End User Easy Button Script
# Safe boundary: read-only, current-user context, no credentials, no mutation, no target inventory in code.

[CmdletBinding()]
param(
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SafeEvidence.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_LOCAL_DRIVE_SPACE_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $drives = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, Size, FreeSpace
    $data = @{
        local_fixed_disk_count = @($drives).Count
        drives = @($drives | ForEach-Object {
            $pct = if ($_.Size -gt 0) { [math]::Round(($_.FreeSpace / $_.Size) * 100, 2) } else { $null }
            @{ drive=$_.DeviceID; size_gb=[math]::Round($_.Size/1GB,2); free_gb=[math]::Round($_.FreeSpace/1GB,2); free_percent=$pct }
        })
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected local fixed disk free space." -Data $data

}
