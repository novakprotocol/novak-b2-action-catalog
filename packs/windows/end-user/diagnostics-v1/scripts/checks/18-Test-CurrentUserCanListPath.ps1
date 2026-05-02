# ENDUSER_TEST_CURRENT_USER_CAN_LIST_PATH_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_TEST_CURRENT_USER_CAN_LIST_PATH_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    if ([string]::IsNullOrWhiteSpace($Path)) { throw "Path is required at runtime." }
    $canList = $false
    $exists = Test-Path -LiteralPath $Path -PathType Container -ErrorAction SilentlyContinue
    if ($exists) {
        try {
            Get-ChildItem -LiteralPath $Path -ErrorAction Stop | Select-Object -First 5 | Out-Null
            $canList = $true
        } catch { $canList = $false }
    }
    $data = @{ path=$Path; folder_exists=[bool]$exists; current_user_can_list=[bool]$canList }
    if ($canList) {
        Write-ItopsResult -Context $ctx -Result "PASS" -Message "Current user can list the folder." -Data $data
    } else {
        Write-ItopsResult -Context $ctx -Result "FAIL" -Message "Current user cannot list the folder or folder is not visible." -Data $data -ExitCode 1
    }

}
