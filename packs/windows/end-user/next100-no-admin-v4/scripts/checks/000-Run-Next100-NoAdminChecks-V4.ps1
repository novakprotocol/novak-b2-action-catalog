# ENDUSER_RUN_NEXT_100_NO_ADMIN_CHECKS_V4
[CmdletBinding()]
param(
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-NoAdminV4.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_RUN_NEXT_100_NO_ADMIN_CHECKS_V4" -EvidenceRoot $EvidenceRoot

$checks = @(
    "161-printer-summary.ps1";
    "162-print-job-summary.ps1";
    "163-default-printer-present.ps1";
    "164-print-spooler-status.ps1";
    "165-printer-cim-count.ps1";
    "166-print-job-cim-count.ps1";
    "167-pnp-printer-class-summary.ps1";
    "168-events-print-service-admin-7d.ps1";
    "169-events-print-service-operational-24h.ps1";
    "170-command-printui-available.ps1";
    "171-command-wmic-available.ps1";
    "172-printer-registry-connections-present.ps1";
    "173-printer-registry-defaults-present.ps1";
    "174-printer-driver-cim-count.ps1";
    "175-printer-port-cim-count.ps1";
    "176-fax-service-status.ps1";
    "177-xps-service-status.ps1";
    "178-printer-process-spoolsv-count.ps1";
    "179-events-spooler-system-24h.ps1";
    "180-printer-user-settings-presence.ps1";
    "181-desktop-top-level-summary.ps1";
    "182-documents-top-level-summary.ps1";
    "183-downloads-top-level-summary.ps1";
    "184-pictures-top-level-summary.ps1";
    "185-music-top-level-summary.ps1";
    "186-videos-top-level-summary.ps1";
    "187-favorites-top-level-summary.ps1";
    "188-desktop-extension-summary.ps1";
    "189-documents-extension-summary.ps1";
    "190-downloads-extension-summary.ps1";
    "191-temp-folder-summary.ps1";
    "192-fixed-disk-free-below-15.ps1";
    "193-fixed-disk-free-below-20.ps1";
    "194-network-drive-summary.ps1";
    "195-shadowcopy-count-user-visible.ps1";
    "196-diskdrive-count-user-visible.ps1";
    "197-partition-count-user-visible.ps1";
    "198-user-shell-folders-personal-presence.ps1";
    "199-explorer-advanced-hidden-presence.ps1";
    "200-explorer-recent-docs-presence.ps1";
    "201-process-winword-count.ps1";
    "202-process-excel-count.ps1";
    "203-process-powerpoint-count.ps1";
    "204-process-onenote-count.ps1";
    "205-process-outlook-count-v2.ps1";
    "206-process-teams-count-v2.ps1";
    "207-process-edge-count-v2.ps1";
    "208-process-chrome-count.ps1";
    "209-process-acrobat-count.ps1";
    "210-process-onedrive-count-v2.ps1";
    "211-onedrive-setup-command-available.ps1";
    "212-office-clicktorun-service-status.ps1";
    "213-office-appx-package-count.ps1";
    "214-powershell-module-count-user-visible.ps1";
    "215-events-office-24h.ps1";
    "216-events-onedrive-24h.ps1";
    "217-events-teams-24h.ps1";
    "218-events-edge-24h.ps1";
    "219-registry-onedrive-account-present.ps1";
    "220-registry-office-common-present.ps1";
    "221-network-category-counts-v2.ps1";
    "222-tcp-connection-state-counts.ps1";
    "223-udp-endpoint-count.ps1";
    "224-route-cim-count.ps1";
    "225-network-adapter-cim-count.ps1";
    "226-network-adapter-config-cim-count.ps1";
    "227-pnp-net-class-summary.ps1";
    "228-pnp-bluetooth-class-summary.ps1";
    "229-bluetooth-service-status.ps1";
    "230-wlan-autoconfig-status.ps1";
    "231-wwan-autoconfig-status.ps1";
    "232-remote-access-service-status.ps1";
    "233-ikeext-service-status.ps1";
    "234-iphlpsvc-service-status.ps1";
    "235-netprofm-service-status.ps1";
    "236-ncb-service-status.ps1";
    "237-nca-service-status.ps1";
    "238-command-netsh-available.ps1";
    "239-command-ipconfig-available.ps1";
    "240-events-vpnish-network-24h.ps1";
    "241-gpresult-command-available-v2.ps1";
    "242-whoami-command-available.ps1";
    "243-cipher-command-available.ps1";
    "244-certutil-command-available.ps1";
    "245-gpupdate-command-available.ps1";
    "246-currentuser-my-cert-count.ps1";
    "247-currentuser-root-cert-count.ps1";
    "248-currentuser-ca-cert-count.ps1";
    "249-scheduled-task-state-counts.ps1";
    "250-startup-approved-count.ps1";
    "251-events-group-policy-operational-24h.ps1";
    "252-events-security-24h-v2.ps1";
    "253-events-defender-operational-24h-v2.ps1";
    "254-events-task-scheduler-operational-24h-v2.ps1";
    "255-events-bits-24h.ps1";
    "256-events-wmi-activity-24h.ps1";
    "257-windows-error-reporting-service-status.ps1";
    "258-problem-reports-registry-presence.ps1";
    "259-remote-desktop-user-setting-presence.ps1";
    "260-support-evidence-root-summary-v2.ps1"
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
    Write-ItopsResult -Context $ctx -Result "FAIL" -Message "One or more no-admin checks failed to launch or returned FAIL." -Data @{ checks=$results; pass_count=$passCount; fail_count=$failCount; warn_count=$warnCount } -ExitCode 1
} elseif ($warnCount -gt 0) {
    Write-ItopsResult -Context $ctx -Result "WARN" -Message "No-admin checks completed with warnings." -Data @{ checks=$results; pass_count=$passCount; fail_count=$failCount; warn_count=$warnCount } -ExitCode 2
} else {
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "All no-admin checks completed with PASS." -Data @{ checks=$results; pass_count=$passCount; fail_count=$failCount; warn_count=$warnCount }
}
