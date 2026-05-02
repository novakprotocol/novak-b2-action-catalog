# ENDUSER_NOADMIN_PARTITION_COUNT_USER_VISIBLE_V1
# Partition count
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_NOADMIN_PARTITION_COUNT_USER_VISIBLE_V1" -EvidenceRoot $EvidenceRoot

$Action = @'
{
    "Type": "CimCount",
    "ClassName": "Win32_DiskPartition"
}
'@ | ConvertFrom-Json

$ActionHashtable = @{}
foreach ($Property in $Action.PSObject.Properties) {
    $ActionHashtable[$Property.Name] = $Property.Value
}

Invoke-ItopsNoAdminAction -Context $ctx -Action $ActionHashtable
