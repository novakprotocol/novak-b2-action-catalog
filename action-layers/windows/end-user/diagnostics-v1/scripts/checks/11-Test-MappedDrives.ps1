# ENDUSER_TEST_MAPPED_DRIVES_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_TEST_MAPPED_DRIVES_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $drives = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.DisplayRoot })
    $results = @()
    foreach ($d in $drives) {
        $path = "$($d.Name):\"
        $exists = Test-Path -LiteralPath $path -ErrorAction SilentlyContinue
        $results += @{ drive="$($d.Name):"; root=$d.DisplayRoot; accessible=[bool]$exists }
    }
    $failCount = @($results | Where-Object { -not $_.accessible }).Count
    $status = if ($failCount -eq 0) { "PASS" } else { "WARN" }
    Write-ItopsResult -Context $ctx -Result $status -Message "Tested mapped drive access for current user." -Data @{ mapped_drive_count=$drives.Count; inaccessible_count=$failCount; drives=$results } -ExitCode $(if ($failCount -eq 0) {0} else {2})

}
