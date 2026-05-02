# ENDUSER_EVERYDAY_BLUETOOTH_WIFI_SERVICES_V1
# Bluetooth and Wi-Fi service group status
# NOVAK B2 Windows Everyday No-Admin Action
# Safe boundary: read-only, current-user context, no credentials, no mutation, no runtime target input.

[CmdletBinding()]
param(
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-EverydayNoAdminV6.ps1"
. $LibPath

$ctx = New-NovakEvidenceContext -ActionId "ENDUSER_EVERYDAY_BLUETOOTH_WIFI_SERVICES_V1" -EvidenceRoot $EvidenceRoot

$Action = @'
{
    "ServiceNames":  [
                         "bthserv",
                         "WlanSvc",
                         "WwanSvc"
                     ],
    "Type":  "ServiceGroupStatus"
}
'@ | ConvertFrom-Json

$ActionHashtable = @{}
foreach ($Property in $Action.PSObject.Properties) {
    $ActionHashtable[$Property.Name] = $Property.Value
}

Invoke-NovakEverydayAction -Context $ctx -Action $ActionHashtable
