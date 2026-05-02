# ENDUSER_NOINPUT_PROXY_ENV_PRESENCE_V1
# Proxy environment variable presence
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

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_NOINPUT_PROXY_ENV_PRESENCE_V1" -EvidenceRoot $EvidenceRoot

$Action = @'
{
    "Type": "EnvVarPresence",
    "EnvNames": [
        "HTTP_PROXY",
        "HTTPS_PROXY",
        "NO_PROXY"
    ]
}
'@ | ConvertFrom-Json

$ActionHashtable = @{}
foreach ($Property in $Action.PSObject.Properties) {
    $ActionHashtable[$Property.Name] = $Property.Value
}

Invoke-ItopsNoInputAction -Context $ctx -Action $ActionHashtable
