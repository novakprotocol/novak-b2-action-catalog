# ENDUSER_GET_MAPPED_DRIVES_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_MAPPED_DRIVES_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.DisplayRoot } | Select-Object Name, DisplayRoot, Description
    $data = @{
        mapped_drive_count = @($drives).Count
        mapped_drives = @($drives | ForEach-Object {
            @{ drive = "$($_.Name):"; root = $_.DisplayRoot; description = $_.Description }
        })
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected mapped drives for current user." -Data $data

}
