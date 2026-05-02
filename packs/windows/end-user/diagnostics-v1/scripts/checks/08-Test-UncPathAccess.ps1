# ENDUSER_TEST_UNC_PATH_ACCESS_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_TEST_UNC_PATH_ACCESS_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    if ([string]::IsNullOrWhiteSpace($Path)) { throw "Path is required at runtime." }
    $exists = Test-Path -LiteralPath $Path -ErrorAction SilentlyContinue
    $canList = $false
    $itemType = "unknown"
    if ($exists) {
        try {
            $item = Get-Item -LiteralPath $Path -ErrorAction Stop
            $itemType = if ($item.PSIsContainer) { "folder" } else { "file" }
            if ($item.PSIsContainer) {
                Get-ChildItem -LiteralPath $Path -Force -ErrorAction Stop | Select-Object -First 1 | Out-Null
                $canList = $true
            }
        } catch {
            $canList = $false
        }
    }
    $data = @{
        path_input_runtime_supplied = $true
        path = $Path
        exists = [bool]$exists
        item_type = $itemType
        can_list_if_folder = [bool]$canList
    }
    if ($exists) {
        Write-ItopsResult -Context $ctx -Result "PASS" -Message "Path exists for current user context." -Data $data
    } else {
        Write-ItopsResult -Context $ctx -Result "FAIL" -Message "Path does not exist or current user cannot see it." -Data $data -ExitCode 1
    }

}
