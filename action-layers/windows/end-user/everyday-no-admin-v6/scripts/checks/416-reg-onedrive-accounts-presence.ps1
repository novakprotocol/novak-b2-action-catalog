# ENDUSER_EVERYDAY_REG_ONEDRIVE_ACCOUNTS_PRESENCE_V1
# OneDrive accounts key presence
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

$ctx = New-NovakEvidenceContext -ActionId "ENDUSER_EVERYDAY_REG_ONEDRIVE_ACCOUNTS_PRESENCE_V1" -EvidenceRoot $EvidenceRoot

$Action = @'
{
    "ValueName":  "dummy_value_name_for_presence_only",
    "RegistryPath":  "HKCU:\\Software\\Microsoft\\OneDrive\\Accounts",
    "Type":  "RegistryPresence"
}
'@ | ConvertFrom-Json

$ActionHashtable = @{}
foreach ($Property in $Action.PSObject.Properties) {
    $ActionHashtable[$Property.Name] = $Property.Value
}

Invoke-NovakEverydayAction -Context $ctx -Action $ActionHashtable
