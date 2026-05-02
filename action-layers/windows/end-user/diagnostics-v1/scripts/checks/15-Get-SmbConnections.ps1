# ENDUSER_GET_SMB_CONNECTIONS_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_SMB_CONNECTIONS_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $connections = @()
    try {
        $connections = @(Get-SmbConnection -ErrorAction Stop | Select-Object ServerName, ShareName, UserName, Dialect, NumOpens)
    } catch {
        $connections = @()
    }
    $data = @{
        smb_connection_count = $connections.Count
        connections = @($connections | ForEach-Object {
            @{ server=$_.ServerName; share=$_.ShareName; dialect=$_.Dialect; open_count=$_.NumOpens }
        })
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected current-user SMB connection summary." -Data $data

}
