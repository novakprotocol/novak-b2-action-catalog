# ENDUSER_GET_DRIVE_LETTER_SUMMARY_V1
# NOenterpriseK B2 Windows End User No-Input Script
# Safe boundary: read-only, current-user context, no credentials, no mutation, no target input, no IP list.

[CmdletBinding()]
param(
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SafeEvidence.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_DRIVE_LETTER_SUMMARY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $disks = @(Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID, DriveType, Size, FreeSpace)
    $items = @()
    foreach ($d in $disks) {
        $freePct = if ($d.Size -and $d.Size -gt 0) { [math]::Round(($d.FreeSpace / $d.Size) * 100, 2) } else { $null }
        $items += @{
            drive = $d.DeviceID
            drive_type = [int]$d.DriveType
            size_gb = if ($d.Size) { [math]::Round($d.Size/1GB,2) } else { $null }
            free_gb = if ($d.FreeSpace) { [math]::Round($d.FreeSpace/1GB,2) } else { $null }
            free_percent = $freePct
        }
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected drive letter summary." -Data @{ drive_count=$items.Count; drives=$items }

}
