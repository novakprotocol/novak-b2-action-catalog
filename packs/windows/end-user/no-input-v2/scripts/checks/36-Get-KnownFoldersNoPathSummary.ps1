# ENDUSER_GET_KNOWN_FOLDERS_NO_PATH_SUMMARY_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_KNOWN_FOLDERS_NO_PATH_SUMMARY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $folders = @{
        Desktop = [Environment]::GetFolderPath("Desktop")
        Documents = [Environment]::GetFolderPath("MyDocuments")
        UserProfile = $env:USERPROFILE
        Downloads = Join-Path $env:USERPROFILE "Downloads"
    }
    $dataFolders = @()
    foreach ($k in $folders.Keys) {
        $p = $folders[$k]
        $dataFolders += @{
            name = $k
            path_value_present = -not [string]::IsNullOrWhiteSpace($p)
            exists = if ([string]::IsNullOrWhiteSpace($p)) { $false } else { Test-Path -LiteralPath $p -ErrorAction SilentlyContinue }
            path_redacted = $true
        }
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected known folder existence summary without recording paths." -Data @{ folders=$dataFolders }

}
