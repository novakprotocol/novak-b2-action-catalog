# ENDUSER_GET_NETWORK_ADAPTER_STATUS_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_NETWORK_ADAPTER_STATUS_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $adapters = Get-NetAdapter -ErrorAction SilentlyContinue | Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress
    $connected = @($adapters | Where-Object { $_.Status -eq "Up" }).Count
    $data = @{
        adapter_count = @($adapters).Count
        connected_adapter_count = $connected
        adapters = @($adapters | ForEach-Object {
            @{
                name = $_.Name
                status = $_.Status
                link_speed = $_.LinkSpeed
                description = $_.InterfaceDescription
            }
        })
    }
    $result = if ($connected -gt 0) { "PASS" } else { "WARN" }
    Write-ItopsResult -Context $ctx -Result $result -Message "Collected network adapter status." -Data $data

}
