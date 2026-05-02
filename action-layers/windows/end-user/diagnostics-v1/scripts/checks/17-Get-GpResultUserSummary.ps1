# ENDUSER_GET_GPRESULT_USER_SUMMARY_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_GPRESULT_USER_SUMMARY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $out = Join-Path $ctx.RunDir "gpresult-user.txt"
    $exit = 0
    try {
        gpresult.exe /scope user /r | Out-File -FilePath $out -Encoding UTF8
    } catch {
        $exit = 1
    }
    $data = @{
        gpresult_file = $out
        gpresult_created = (Test-Path -LiteralPath $out)
        note = "Output is local evidence. Review before attaching to tickets."
    }
    Write-ItopsResult -Context $ctx -Result $(if ($exit -eq 0) {"PASS"} else {"WARN"}) -Message "Generated user-scope GPResult summary." -Data $data -ExitCode $exit

}
