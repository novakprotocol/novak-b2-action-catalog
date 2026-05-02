# ENDUSER_NOINPUT_EVENTS_NETWORK_24H_V1
# Recent network warning/error count
# NOenterpriseK B2 Windows End User Next 100 No-Input Script
# Safe boundary: read-only, current-user context, no credentials, no mutation, no target input, no IP list.

[CmdletBinding()]
param(
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-Next100NoInput.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_NOINPUT_EVENTS_NETWORK_24H_V1" -EvidenceRoot $EvidenceRoot

$Action = @'
{
    "Type": "EventCount",
    "LogName": "System",
    "HoursBack": 24,
    "ProviderPatterns": [
        "Tcpip",
        "DNS",
        "Netlogon",
        "NlaSvc",
        "Dhcp",
        "WLAN",
        "Netwtw"
    ]
}
'@ | ConvertFrom-Json

$ActionHashtable = @{}
foreach ($Property in $Action.PSObject.Properties) {
    $ActionHashtable[$Property.Name] = $Property.Value
}

Invoke-ItopsNoInputAction -Context $ctx -Action $ActionHashtable
