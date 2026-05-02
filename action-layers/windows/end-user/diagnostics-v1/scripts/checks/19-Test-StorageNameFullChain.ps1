# ENDUSER_TEST_STORAGE_NAME_FULL_CHAIN_V1
# NOenterpriseK B2 Windows End User Easy Button Script
# Safe boundary: read-only, current-user context, no credentials, no mutation, no target inventory in code.

[CmdletBinding()]
param(
    [string]$TargetName,
    [int[]]$Ports = @(445,443),
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SafeEvidence.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_TEST_STORAGE_NAME_FULL_CHAIN_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    if ([string]::IsNullOrWhiteSpace($TargetName)) { throw "TargetName is required at runtime." }
    $dnsOk = $false
    try { Resolve-DnsName -Name $TargetName -ErrorAction Stop | Select-Object -First 1 | Out-Null; $dnsOk = $true } catch {}
    $pingOk = Test-Connection -ComputerName $TargetName -Count 2 -Quiet -ErrorAction SilentlyContinue
    $portResults = @()
    foreach ($p in $Ports) {
        try {
            $tnc = Test-NetConnection -ComputerName $TargetName -Port $p -WarningAction SilentlyContinue
            $portResults += @{ port=$p; tcp=[bool]$tnc.TcpTestSucceeded }
        } catch {
            $portResults += @{ port=$p; tcp=$false }
        }
    }
    $anyPort = @($portResults | Where-Object { $_.tcp }).Count -gt 0
    $status = if ($dnsOk -and $anyPort) { "PASS" } elseif ($dnsOk -or $pingOk -or $anyPort) { "WARN" } else { "FAIL" }
    $data = @{ target_name=$TargetName; dns_resolved=$dnsOk; ping_replied=[bool]$pingOk; port_results=$portResults }
    Write-ItopsResult -Context $ctx -Result $status -Message "Completed basic storage name chain test." -Data $data -ExitCode $(if ($status -eq "FAIL") {1} elseif ($status -eq "WARN") {2} else {0})

}
