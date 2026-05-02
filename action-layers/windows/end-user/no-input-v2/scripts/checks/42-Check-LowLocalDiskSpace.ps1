# ENDUSER_CHECK_LOW_LOCAL_DISK_SPACE_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_CHECK_LOW_LOCAL_DISK_SPACE_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $threshold = 10
    $disks = @(Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, Size, FreeSpace)
    $items = @()
    $low = 0
    foreach ($d in $disks) {
        $freePct = if ($d.Size -and $d.Size -gt 0) { [math]::Round(($d.FreeSpace / $d.Size) * 100, 2) } else { $null }
        if ($null -ne $freePct -and $freePct -lt $threshold) { $low++ }
        $items += @{ drive=$d.DeviceID; free_percent=$freePct; below_threshold=($null -ne $freePct -and $freePct -lt $threshold) }
    }
    $status = if ($low -eq 0) { "PASS" } else { "WARN" }
    Write-ItopsResult -Context $ctx -Result $status -Message "Checked local fixed disks for low free space." -Data @{ threshold_percent=$threshold; low_disk_count=$low; disks=$items } -ExitCode $(if ($low -eq 0) {0} else {2})

}
