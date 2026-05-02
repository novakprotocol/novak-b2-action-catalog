# ENDUSER_GET_USER_COMPUTER_CONTEXT_V1
# NOenterpriseK B2 Windows End User Easy Button Script
# Safe boundary: read-only, current-user context, no credentials, no mutation, no target inventory in code.

[CmdletBinding()]
param(
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SafeEvidence.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_GET_USER_COMPUTER_CONTEXT_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $data = @{
        computer_name = $env:COMPUTERNAME
        user_domain = $env:USERDOMAIN
        username = $env:USERNAME
        user_dns_domain = $env:USERDNSDOMAIN
        logon_server_present = -not [string]::IsNullOrWhiteSpace($env:LOGONSERVER)
        powershell_version = $PSVersionTable.PSVersion.ToString()
        os_caption = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
    }
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "Collected current user and computer context." -Data $data

}
