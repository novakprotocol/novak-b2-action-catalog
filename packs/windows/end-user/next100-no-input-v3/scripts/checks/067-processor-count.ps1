# ENDUSER_NOINPUT_PROCESSOR_COUNT_V1
# Processor instance count
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_NOINPUT_PROCESSOR_COUNT_V1" -EvidenceRoot $EvidenceRoot

$Action = @'
{
    "Type": "CimCount",
    "ClassName": "Win32_Processor"
}
'@ | ConvertFrom-Json

$ActionHashtable = @{}
foreach ($Property in $Action.PSObject.Properties) {
    $ActionHashtable[$Property.Name] = $Property.Value
}

Invoke-ItopsNoInputAction -Context $ctx -Action $ActionHashtable
