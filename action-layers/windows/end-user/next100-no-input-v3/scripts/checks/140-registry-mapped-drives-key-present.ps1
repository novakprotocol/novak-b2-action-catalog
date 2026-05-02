# ENDUSER_NOINPUT_REGISTRY_MAPPED_DRIVES_KEY_PRESENT_V1
# Network mapped drives key presence
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_NOINPUT_REGISTRY_MAPPED_DRIVES_KEY_PRESENT_V1" -EvidenceRoot $EvidenceRoot

$Action = @'
{
    "Type": "RegistryValuePresent",
    "RegistryPath": "HKCU:\\Network",
    "ValueName": "dummy_value_name_for_presence_only"
}
'@ | ConvertFrom-Json

$ActionHashtable = @{}
foreach ($Property in $Action.PSObject.Properties) {
    $ActionHashtable[$Property.Name] = $Property.Value
}

Invoke-ItopsNoInputAction -Context $ctx -Action $ActionHashtable
