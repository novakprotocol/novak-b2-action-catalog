# ENDUSER_NOADMIN_EVENTS_OFFICE_24H_V1
# Office-related event count last 24h
# NOenterpriseK B2 Windows End User No-Admin Script v4
# Safe boundary: read-only, current-user context, no admin, no credentials, no mutation, no runtime target input, no IP list.

[CmdletBinding()]
param(
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-NoAdminV4.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_NOADMIN_EVENTS_OFFICE_24H_V1" -EvidenceRoot $EvidenceRoot

$Action = @'
{
    "Type": "EventCount",
    "LogName": "Application",
    "HoursBack": 24,
    "ProviderPatterns": [
        "Office",
        "Microsoft Office",
        "Outlook",
        "Excel",
        "Word",
        "PowerPoint"
    ]
}
'@ | ConvertFrom-Json

$ActionHashtable = @{}
foreach ($Property in $Action.PSObject.Properties) {
    $ActionHashtable[$Property.Name] = $Property.Value
}

Invoke-ItopsNoAdminAction -Context $ctx -Action $ActionHashtable
