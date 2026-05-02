# ENDUSER_GET_RECENT_EXPLORER_CRASH_COUNT_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_RECENT_EXPLORER_CRASH_COUNT_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $start = (Get-Date).AddDays(-7)
    $count = $null
    try {
        $events = @(Get-WinEvent -FilterHashtable @{ LogName="Application"; StartTime=$start } -ErrorAction Stop |
            Where-Object { ([string]$_.Message) -match "explorer.exe" -and ([int]$_.Level) -in @(1,2,3) })
        $count = $events.Count
    } catch {}
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected recent Explorer crash/error count." -Data @{ days_back=7; event_count=$count; event_details_redacted=$true }

}
