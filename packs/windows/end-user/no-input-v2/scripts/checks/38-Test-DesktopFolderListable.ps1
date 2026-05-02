# ENDUSER_TEST_DESKTOP_FOLDER_LISTABLE_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_TEST_DESKTOP_FOLDER_LISTABLE_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $p = [Environment]::GetFolderPath("Desktop")
    $exists = -not [string]::IsNullOrWhiteSpace($p) -and (Test-Path -LiteralPath $p -PathType Container -ErrorAction SilentlyContinue)
    $canList = $false
    if ($exists) { try { Get-ChildItem -LiteralPath $p -ErrorAction Stop | Select-Object -First 1 | Out-Null; $canList = $true } catch {} }
    $status = if ($exists -and $canList) { "PASS" } elseif ($exists) { "WARN" } else { "FAIL" }
    Write-ItopsResult -Context $ctx -Result $status -Message "Checked Desktop folder visibility/listability without recording path." -Data @{ exists=$exists; can_list=$canList; path_redacted=$true } -ExitCode $(if ($status -eq "PASS") {0} elseif ($status -eq "WARN") {2} else {1})

}
