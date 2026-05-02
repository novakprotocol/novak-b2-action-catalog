# ENDUSER_EVERYDAY_EVENTS_KERNEL_POWER_7D_V1
# Kernel-Power event count last 7 days
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

$ctx = New-NovakEvidenceContext -ActionId "ENDUSER_EVERYDAY_EVENTS_KERNEL_POWER_7D_V1" -EvidenceRoot $EvidenceRoot

$Action = @'
{
    "ProviderPatterns":  [
                             "Kernel-Power"
                         ],
    "LogName":  "System",
    "Type":  "EventCount",
    "HoursBack":  168
}
'@ | ConvertFrom-Json

$ActionHashtable = @{}
foreach ($Property in $Action.PSObject.Properties) {
    $ActionHashtable[$Property.Name] = $Property.Value
}

Invoke-NovakEverydayAction -Context $ctx -Action $ActionHashtable
