# ENDUSER_RUN_NEXT_100_NO_INPUT_CHECKS_V3
[CmdletBinding()]
param(
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-Next100NoInput.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_RUN_NEXT_100_NO_INPUT_CHECKS_V3" -EvidenceRoot $EvidenceRoot

$checks = @(
    "061-os-caption-presence.ps1";
    "062-os-version-presence.ps1";
    "063-os-install-date-presence.ps1";
    "064-os-architecture-presence.ps1";
    "065-computer-manufacturer-presence.ps1";
    "066-computer-memory-presence.ps1";
    "067-processor-count.ps1";
    "068-bios-property-presence.ps1";
    "069-battery-instance-count.ps1";
    "070-portable-chassis-presence.ps1";
    "071-hotfix-count.ps1";
    "072-logged-on-user-presence.ps1";
    "073-timezone-presence.ps1";
    "074-pagefile-count.ps1";
    "075-print-queue-count.ps1";
    "076-logical-disk-count.ps1";
    "077-volume-count.ps1";
    "078-share-count-local.ps1";
    "079-startup-command-count.ps1";
    "080-user-profile-count.ps1";
    "081-service-w32time-status.ps1";
    "082-service-dnscache-status.ps1";
    "083-service-lanmanworkstation-status.ps1";
    "084-service-lanmanserver-status.ps1";
    "085-service-webclient-status.ps1";
    "086-service-cscservice-status.ps1";
    "087-service-wsearch-status.ps1";
    "088-service-bits-status.ps1";
    "089-service-wuauserv-status.ps1";
    "090-service-eventlog-status.ps1";
    "091-service-schedule-status.ps1";
    "092-service-dhcp-status.ps1";
    "093-service-nlasvc-status.ps1";
    "094-service-netlogon-status.ps1";
    "095-service-cryptsvc-status.ps1";
    "096-service-winmgmt-status.ps1";
    "097-service-lmhosts-status.ps1";
    "098-service-policyagent-status.ps1";
    "099-service-mpssvc-status.ps1";
    "100-service-sense-status.ps1";
    "101-service-windefend-status.ps1";
    "102-service-vss-status.ps1";
    "103-service-swprv-status.ps1";
    "104-service-storsvc-status.ps1";
    "105-service-wersvc-status.ps1";
    "106-network-adapter-counts.ps1";
    "107-network-profile-counts.ps1";
    "108-dns-config-counts.ps1";
    "109-smb-summary-counts.ps1";
    "110-firewall-profile-counts.ps1";
    "111-command-ping-available.ps1";
    "112-command-nslookup-available.ps1";
    "113-command-tracert-available.ps1";
    "114-command-gpresult-available.ps1";
    "115-command-klist-available.ps1";
    "116-command-net-use-available.ps1";
    "117-command-robocopy-available.ps1";
    "118-command-wevtutil-available.ps1";
    "119-process-onedrive-count.ps1";
    "120-process-explorer-count.ps1";
    "121-process-teams-count.ps1";
    "122-process-outlook-count.ps1";
    "123-process-edge-count.ps1";
    "124-proxy-env-presence.ps1";
    "125-storage-env-presence.ps1";
    "126-known-folder-desktop.ps1";
    "127-known-folder-documents.ps1";
    "128-known-folder-downloads.ps1";
    "129-known-folder-pictures.ps1";
    "130-known-folder-music.ps1";
    "131-known-folder-videos.ps1";
    "132-known-folder-favorites.ps1";
    "133-drive-all-summary.ps1";
    "134-drive-fixed-summary.ps1";
    "135-drive-network-summary.ps1";
    "136-drive-removable-summary.ps1";
    "137-registry-long-paths-present.ps1";
    "138-registry-offline-files-policy-present.ps1";
    "139-registry-user-shell-folders-present.ps1";
    "140-registry-mapped-drives-key-present.ps1";
    "141-evidence-root-summary.ps1";
    "142-power-plan-presence.ps1";
    "143-cim-shadowcopy-count.ps1";
    "144-cim-diskdrive-count.ps1";
    "145-cim-partition-count.ps1";
    "146-events-network-24h.ps1";
    "147-events-disk-ntfs-24h.ps1";
    "148-events-smb-24h.ps1";
    "149-events-group-policy-24h.ps1";
    "150-events-service-control-24h.ps1";
    "151-events-windows-update-24h.ps1";
    "152-events-application-errors-24h.ps1";
    "153-events-powershell-24h.ps1";
    "154-events-wmi-24h.ps1";
    "155-events-onedrive-7d.ps1";
    "156-events-explorer-7d.ps1";
    "157-events-security-audit-count-24h.ps1";
    "158-events-defender-24h.ps1";
    "159-events-task-scheduler-24h.ps1";
    "160-events-terminal-services-24h.ps1"
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
    Write-ItopsResult -Context $ctx -Result "FAIL" -Message "One or more next-100 checks failed to launch or returned FAIL." -Data @{ checks=$results; pass_count=$passCount; fail_count=$failCount; warn_count=$warnCount } -ExitCode 1
} elseif ($warnCount -gt 0) {
    Write-ItopsResult -Context $ctx -Result "WARN" -Message "Next-100 checks completed with warnings." -Data @{ checks=$results; pass_count=$passCount; fail_count=$failCount; warn_count=$warnCount } -ExitCode 2
} else {
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "All next-100 no-input checks completed with PASS." -Data @{ checks=$results; pass_count=$passCount; fail_count=$failCount; warn_count=$warnCount }
}
