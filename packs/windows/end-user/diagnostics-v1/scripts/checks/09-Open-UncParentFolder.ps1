# ENDUSER_OPEN_UNC_PARENT_FOLDER_V1
# NOenterpriseK B2 Windows End User Easy Button Script
# Safe boundary: read-only, current-user context, no credentials, no mutation, no target inventory in code.

[CmdletBinding()]
param(
    [string]$Path,
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SafeEvidence.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_OPEN_UNC_PARENT_FOLDER_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    if ([string]::IsNullOrWhiteSpace($Path)) { throw "Path is required at runtime." }
    $target = $Path
    if (Test-Path -LiteralPath $Path -PathType Leaf -ErrorAction SilentlyContinue) {
        $target = Split-Path -Parent $Path
    }
    if (-not (Test-Path -LiteralPath $target -ErrorAction SilentlyContinue)) {
        Write-ItopsResult -Context $ctx -Result "FAIL" -Message "Parent folder does not exist or current user cannot access it." -Data @{ path=$Path; parent=$target } -ExitCode 1
    }
    Start-Process explorer.exe -ArgumentList $target
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Opened folder in Explorer." -Data @{ path=$Path; opened=$target }

}
