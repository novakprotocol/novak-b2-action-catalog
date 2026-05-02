# ENDUSER_RUN_EVERYDAY_NO_ADMIN_ACTIONS_V6
[CmdletBinding()]
param(
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-EverydayNoAdminV6.ps1"
. $LibPath

$ctx = New-NovakEvidenceContext -ActionId "ENDUSER_RUN_EVERYDAY_NO_ADMIN_ACTIONS_V6" -EvidenceRoot $EvidenceRoot

$checks = @(
    "341-path-health-desktop.ps1";
    "342-path-health-documents.ps1";
    "343-path-health-downloads.ps1";
    "344-path-health-pictures.ps1";
    "345-path-health-videos.ps1";
    "346-path-health-music.ps1";
    "347-path-health-userprofile.ps1";
    "348-old-files-desktop-30d.ps1";
    "349-old-files-desktop-90d.ps1";
    "350-office-ext-desktop.ps1";
    "351-old-files-documents-30d.ps1";
    "352-old-files-documents-90d.ps1";
    "353-office-ext-documents.ps1";
    "354-old-files-downloads-30d.ps1";
    "355-old-files-downloads-90d.ps1";
    "356-office-ext-downloads.ps1";
    "357-env-office-presence.ps1";
    "358-env-user-profile-presence.ps1";
    "359-env-path-presence.ps1";
    "360-env-proxy-presence-v2.ps1";
    "361-command-where-exe.ps1";
    "362-command-whoami-exe.ps1";
    "363-command-hostname-exe.ps1";
    "364-command-net-exe.ps1";
    "365-command-netstat-exe.ps1";
    "366-command-pathping-exe.ps1";
    "367-command-route-exe.ps1";
    "368-command-arp-exe.ps1";
    "369-command-powershell-exe.ps1";
    "370-command-cmd-exe.ps1";
    "371-command-control-exe.ps1";
    "372-command-msinfo32-exe.ps1";
    "373-command-perfmon-exe.ps1";
    "374-command-cleanmgr-exe.ps1";
    "375-command-eventvwr-msc.ps1";
    "376-command-compmgmt-msc.ps1";
    "377-command-dxdiag-exe.ps1";
    "378-command-magnify-exe.ps1";
    "379-command-osk-exe.ps1";
    "380-command-snippingtool-exe.ps1";
    "381-browser-process-group.ps1";
    "382-office-process-group.ps1";
    "383-collaboration-process-group.ps1";
    "384-shell-process-group.ps1";
    "385-security-process-group.ps1";
    "386-pdf-process-group.ps1";
    "387-sync-process-group.ps1";
    "388-remote-access-process-group.ps1";
    "389-core-network-services.ps1";
    "390-core-windows-services.ps1";
    "391-file-sharing-services.ps1";
    "392-security-services.ps1";
    "393-printer-services.ps1";
    "394-bluetooth-wifi-services.ps1";
    "395-remote-access-services.ps1";
    "396-profile-services.ps1";
    "397-events-app-hang-7d.ps1";
    "398-events-app-error-7d.ps1";
    "399-events-windows-error-reporting-7d.ps1";
    "400-events-dns-client-24h.ps1";
    "401-events-dhcp-24h.ps1";
    "402-events-nla-24h.ps1";
    "403-events-smbclient-7d.ps1";
    "404-events-offlinefiles-7d.ps1";
    "405-events-userprofile-7d.ps1";
    "406-events-print-7d.ps1";
    "407-events-kernel-power-7d.ps1";
    "408-events-disk-7d.ps1";
    "409-events-defender-7d.ps1";
    "410-events-task-scheduler-7d.ps1";
    "411-events-powershell-7d.ps1";
    "412-reg-explorer-advanced-hidden.ps1";
    "413-reg-explorer-show-super-hidden.ps1";
    "414-reg-explorer-hide-file-ext.ps1";
    "415-reg-run-key-presence.ps1";
    "416-reg-onedrive-accounts-presence.ps1";
    "417-reg-terminal-client-presence.ps1";
    "418-cert-my-count-v2.ps1";
    "419-cert-root-count-v2.ps1";
    "420-cert-ca-count-v2.ps1";
    "421-cim-sound-device-count.ps1";
    "422-cim-usb-controller-count.ps1";
    "423-cim-desktop-monitor-count.ps1";
    "424-cim-keyboard-count.ps1";
    "425-cim-pointing-device-count.ps1";
    "426-scheduled-task-summary-v2.ps1";
    "427-network-state-count-v2.ps1";
    "428-command-optional-tool-88.ps1";
    "429-command-optional-tool-89.ps1";
    "430-command-optional-tool-90.ps1";
    "431-command-optional-tool-91.ps1";
    "432-command-optional-tool-92.ps1";
    "433-command-optional-tool-93.ps1";
    "434-command-optional-tool-94.ps1";
    "435-command-optional-tool-95.ps1";
    "436-command-optional-tool-96.ps1";
    "437-command-optional-tool-97.ps1";
    "438-command-optional-tool-98.ps1";
    "439-command-optional-tool-99.ps1";
    "440-command-optional-tool-100.ps1"
)

$results = @()
foreach ($c in $checks) {
    $path = Join-Path $ScriptDir $c
    try {
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File $path -EvidenceRoot $ctx.RunDir
        $results += @{ check=$c; launched=$true; exit_code=$LASTEXITCODE }
    } catch {
        $results += @{ check=$c; launched=$false; exit_code=99; error=$_.Exception.Message }
    }
}

$failCount = @($results | Where-Object { $_.exit_code -eq 1 -or $_.launched -eq $false }).Count
$warnCount = @($results | Where-Object { $_.exit_code -eq 2 }).Count
$passCount = @($results | Where-Object { $_.exit_code -eq 0 }).Count

if ($failCount -gt 0) {
    Write-NovakResult -Context $ctx -Result "FAIL" -Message "One or more everyday no-admin actions failed to launch or returned FAIL." -Data @{ checks=$results; pass_count=$passCount; fail_count=$failCount; warn_count=$warnCount } -ExitCode 1
} elseif ($warnCount -gt 0) {
    Write-NovakResult -Context $ctx -Result "WARN" -Message "Everyday no-admin actions completed with warnings." -Data @{ checks=$results; pass_count=$passCount; fail_count=$failCount; warn_count=$warnCount } -ExitCode 2
} else {
    Write-NovakResult -Context $ctx -Result "PASS" -Message "All everyday no-admin actions completed with PASS." -Data @{ checks=$results; pass_count=$passCount; fail_count=$failCount; warn_count=$warnCount }
}
