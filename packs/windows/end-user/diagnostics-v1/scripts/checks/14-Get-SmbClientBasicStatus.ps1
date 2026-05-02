# ENDUSER_GET_SMB_CLIENT_BASIC_STATUS_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_SMB_CLIENT_BASIC_STATUS_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $cfg = $null
    try { $cfg = Get-SmbClientConfiguration -ErrorAction Stop } catch {}
    $data = @{
        smb_client_config_available = $null -ne $cfg
        enable_security_signature = if ($cfg) { [bool]$cfg.EnableSecuritySignature } else { $null }
        require_security_signature = if ($cfg) { [bool]$cfg.RequireSecuritySignature } else { $null }
        enable_multichannel = if ($cfg) { [bool]$cfg.EnableMultiChannel } else { $null }
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected basic SMB client configuration." -Data $data

}
