# ENDUSER_SELF_FIX_CLEAR_RECENT_ITEMS_V1
# Clear Recent Items
# NOenterpriseK B2 Windows End User Self-Fix Candidate v5
# Safe boundary: current-user context, no admin by design, no credentials, no target inventory.
# IMPORTANT: This script is dry-run by default. It only changes user-scope state when -Apply is supplied.

[CmdletBinding()]
param(
    [switch]$Apply,
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SelfFixV5.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_SELF_FIX_CLEAR_RECENT_ITEMS_V1" -EvidenceRoot $EvidenceRoot

$Action = @'
{
    "Type": "ClearKnownFolder",
    "FolderKind": "Recent",
    "OlderThanDays": 0
}
'@ | ConvertFrom-Json

$ActionHashtable = @{}
foreach ($Property in $Action.PSObject.Properties) {
    $ActionHashtable[$Property.Name] = $Property.Value
}

Invoke-ItopsSelfFixAction -Context $ctx -Action $ActionHashtable -Apply ([bool]$Apply)
