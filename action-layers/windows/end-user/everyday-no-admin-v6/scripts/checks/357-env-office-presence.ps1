# ENDUSER_EVERYDAY_ENV_OFFICE_PRESENCE_V1
# Office-related environment variable presence
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

$ctx = New-NovakEvidenceContext -ActionId "ENDUSER_EVERYDAY_ENV_OFFICE_PRESENCE_V1" -EvidenceRoot $EvidenceRoot

$Action = @'
{
    "Type":  "EnvPresence",
    "Names":  [
                  "OneDrive",
                  "OneDriveCommercial",
                  "OneDriveConsumer",
                  "TEMP",
                  "TMP",
                  "APPDATA",
                  "LOCALAPPDATA"
              ]
}
'@ | ConvertFrom-Json

$ActionHashtable = @{}
foreach ($Property in $Action.PSObject.Properties) {
    $ActionHashtable[$Property.Name] = $Property.Value
}

Invoke-NovakEverydayAction -Context $ctx -Action $ActionHashtable
