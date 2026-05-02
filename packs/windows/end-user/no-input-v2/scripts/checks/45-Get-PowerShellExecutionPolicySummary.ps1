# ENDUSER_GET_POWERSHELL_EXECUTION_POLICY_SUMMARY_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_POWERSHELL_EXECUTION_POLICY_SUMMARY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $policies = @(Get-ExecutionPolicy -List | ForEach-Object { @{ scope=[string]$_.Scope; policy=[string]$_.ExecutionPolicy } })
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected PowerShell execution policy summary." -Data @{ policies=$policies }

}
