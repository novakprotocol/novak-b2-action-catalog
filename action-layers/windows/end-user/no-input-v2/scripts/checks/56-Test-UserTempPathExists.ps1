# ENDUSER_TEST_USER_TEMP_PATH_EXISTS_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_TEST_USER_TEMP_PATH_EXISTS_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $tmp = [System.IO.Path]::GetTempPath()
    $exists = Test-Path -LiteralPath $tmp -PathType Container -ErrorAction SilentlyContinue
    Write-ItopsResult -Context $ctx -Result $(if ($exists) {"PASS"} else {"FAIL"}) -Message "Checked whether user temp path exists without writing a temp file." -Data @{ temp_path_exists=$exists; path_redacted=$true } -ExitCode $(if ($exists) {0} else {1})

}
