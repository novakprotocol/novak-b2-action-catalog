# ENDUSER_TEST_URL_STATUS_V1
# NOenterpriseK B2 Windows End User Easy Button Script
# Safe boundary: read-only, current-user context, no credentials, no mutation, no target inventory in code.

[CmdletBinding()]
param(
    [string]$TargetUrl,
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SafeEvidence.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_TEST_URL_STATUS_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    if ([string]::IsNullOrWhiteSpace($TargetUrl)) { throw "TargetUrl is required at runtime." }
    if ($TargetUrl -notmatch '^https?://') { throw "TargetUrl must start with http:// or https://." }
    $statusCode = $null
    $ok = $false
    try {
        $resp = Invoke-WebRequest -Uri $TargetUrl -Method Head -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
        $statusCode = [int]$resp.StatusCode
        $ok = $statusCode -ge 100 -and $statusCode -lt 500
    } catch {
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
            $statusCode = [int]$_.Exception.Response.StatusCode
            $ok = $statusCode -ge 100 -and $statusCode -lt 500
        }
    }
    $data = @{
        target_input_runtime_supplied = $true
        target_url = $TargetUrl
        http_status = $statusCode
        responded = $ok
    }
    if ($ok) {
        Write-ItopsResult -Context $ctx -Result "PASS" -Message "URL responded with an HTTP status." -Data $data
    } else {
        Write-ItopsResult -Context $ctx -Result "FAIL" -Message "URL did not respond with usable HTTP status." -Data $data -ExitCode 1
    }

}
