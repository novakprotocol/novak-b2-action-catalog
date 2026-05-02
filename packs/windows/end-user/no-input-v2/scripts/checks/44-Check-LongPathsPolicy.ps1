# ENDUSER_CHECK_LONG_PATHS_POLICY_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_CHECK_LONG_PATHS_POLICY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $enabled = $null
    try {
        $v = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -ErrorAction Stop
        $enabled = [int]$v.LongPathsEnabled
    } catch {}
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Read long path policy value if accessible." -Data @{ long_paths_enabled_value=$enabled; accessible=($null -ne $enabled) }

}
