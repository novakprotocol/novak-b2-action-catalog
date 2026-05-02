# ENDUSER_GET_RECENT_STORAGE_EVENTS_V1
# NOenterpriseK B2 Windows End User Easy Button Script
# Safe boundary: read-only, current-user context, no credentials, no mutation, no target inventory in code.

[CmdletBinding()]
param(
    [string]$EvidenceRoot = "",
    [int]$HoursBack = 24
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SafeEvidence.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_RECENT_STORAGE_EVENTS_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $start = (Get-Date).AddHours(-1 * [math]::Abs($HoursBack))
    $events = @()
    try {
        $events = @(Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$start} -ErrorAction Stop |
            Where-Object { $_.ProviderName -match 'disk|ntfs|smb|srv|lanman|dfs|mrxsmb|netlogon|dns' } |
            Select-Object -First 50 TimeCreated, Id, ProviderName, LevelDisplayName, Message)
    } catch {
        $events = @()
    }
    $data = @{
        hours_back = $HoursBack
        event_count_limited_to_50 = $events.Count
        events = @($events | ForEach-Object {
            @{ time=$_.TimeCreated.ToString("o"); id=$_.Id; provider=$_.ProviderName; level=$_.LevelDisplayName; message_excerpt=([string]$_.Message).Substring(0, [Math]::Min(240, ([string]$_.Message).Length)) }
        })
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected recent storage-adjacent System events, limited to 50." -Data $data

}
