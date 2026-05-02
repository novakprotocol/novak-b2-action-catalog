# ENDUSER_GET_WINDOWS_UPTIME_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_WINDOWS_UPTIME_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $os = Get-CimInstance Win32_OperatingSystem
    $lastBoot = $os.LastBootUpTime
    $uptime = (Get-Date) - $lastBoot
    $data = @{
        last_boot_time = $lastBoot.ToString("o")
        uptime_hours = [math]::Round($uptime.TotalHours, 2)
        uptime_days = [math]::Round($uptime.TotalDays, 2)
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected Windows uptime." -Data $data

}
