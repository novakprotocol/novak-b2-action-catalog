# ENDUSER_CHECK_PENDING_REBOOT_INDICATORS_V1
# NOenterpriseK B2 Windows End User No-Input Script
# Safe boundary: read-only, current-user context, no credentials, no mutation, no target input, no IP list.

[CmdletBinding()]
param(
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SafeEvidence.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_CHECK_PENDING_REBOOT_INDICATORS_V1" -EvidenceRoot $EvidenceRoot

Invoke-ItopsSafe -Context $ctx -ScriptBlock {

    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager"
    )
    $cbs = Test-Path $paths[0]
    $wu = Test-Path $paths[1]
    $pendingFileRename = $false
    try {
        $v = Get-ItemProperty -Path $paths[2] -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
        $pendingFileRename = $null -ne $v.PendingFileRenameOperations
    } catch {}
    $pending = $cbs -or $wu -or $pendingFileRename
    $data = @{
        component_based_servicing_reboot_pending = [bool]$cbs
        windows_update_reboot_required = [bool]$wu
        pending_file_rename_operations = [bool]$pendingFileRename
        reboot_likely_pending = [bool]$pending
    }
    Write-ItopsResult -Context $ctx -Result $(if ($pending) {"WARN"} else {"PASS"}) -Message $(if ($pending) {"Pending reboot indicator found."} else {"No common pending reboot indicators found."}) -Data $data -ExitCode $(if ($pending) {2} else {0})

}
