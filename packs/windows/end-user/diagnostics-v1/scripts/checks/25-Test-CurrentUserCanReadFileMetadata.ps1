# ENDUSER_TEST_CURRENT_USER_CAN_READ_FILE_METADATA_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_TEST_CURRENT_USER_CAN_READ_FILE_METADATA_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    if ([string]::IsNullOrWhiteSpace($Path)) { throw "Path is required at runtime." }
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf -ErrorAction SilentlyContinue)) {
        Write-ItopsResult -Context $ctx -Result "FAIL" -Message "File is not visible to current user." -Data @{ path=$Path } -ExitCode 1
    }
    $item = Get-Item -LiteralPath $Path -ErrorAction Stop
    $data = @{
        path=$Path
        name=$item.Name
        length_bytes=$item.Length
        extension=$item.Extension
        last_write_time=$item.LastWriteTime.ToString("o")
        read_content_performed=$false
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Current user can read file metadata. File contents were not read." -Data $data

}
