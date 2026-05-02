# ENDUSER_GET_DNS_CLIENT_SUMMARY_V1
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_DNS_CLIENT_SUMMARY_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $dns = Get-DnsClient -ErrorAction SilentlyContinue | Select-Object InterfaceAlias, ConnectionSpecificSuffix, RegisterThisConnectionsAddress, UseSuffixWhenRegistering
    $servers = Get-DnsClientServerAddress -ErrorAction SilentlyContinue | Where-Object {$_.AddressFamily -eq 2} | Select-Object InterfaceAlias, ServerAddresses
    $data = @{
        dns_client_entries = @($dns | ForEach-Object {
            @{
                interface_alias = $_.InterfaceAlias
                connection_suffix_present = -not [string]::IsNullOrWhiteSpace($_.ConnectionSpecificSuffix)
                register_address = [bool]$_.RegisterThisConnectionsAddress
                use_suffix_when_registering = [bool]$_.UseSuffixWhenRegistering
            }
        })
        dns_server_entries = @($servers | ForEach-Object {
            @{
                interface_alias = $_.InterfaceAlias
                server_count = @($_.ServerAddresses).Count
            }
        })
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected DNS client summary without writing server IPs to evidence." -Data $data

}
