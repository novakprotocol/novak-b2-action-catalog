# ENDUSER_RUN_ALL_SELF_FIX_CANDIDATES_V5_PLAN_ONLY
[CmdletBinding()]
param(
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SelfFixV5.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_RUN_ALL_SELF_FIX_CANDIDATES_V5_PLAN_ONLY" -EvidenceRoot $EvidenceRoot

$checks = @(
    "261-restart-explorer.ps1";
    "262-open-documents-folder.ps1";
    "263-open-downloads-folder.ps1";
    "264-open-desktop-folder.ps1";
    "265-open-pictures-folder.ps1";
    "266-open-selfcheck-evidence-folder.ps1";
    "267-create-support-evidence-zip.ps1";
    "268-clear-clipboard.ps1";
    "269-flush-dns-cache.ps1";
    "270-gpupdate-user-policy.ps1";
    "271-gpupdate-user-policy-wait-zero.ps1";
    "272-purge-kerberos-tickets.ps1";
    "273-open-credential-manager.ps1";
    "274-open-internet-options.ps1";
    "275-open-network-connections.ps1";
    "276-open-printers-settings.ps1";
    "277-restart-onedrive.ps1";
    "278-start-onedrive.ps1";
    "279-restart-teams.ps1";
    "280-restart-outlook.ps1";
    "281-restart-word.ps1";
    "282-restart-excel.ps1";
    "283-restart-powerpoint.ps1";
    "284-restart-edge.ps1";
    "285-restart-chrome.ps1";
    "286-clear-user-temp-older-7-days.ps1";
    "287-clear-user-temp-all.ps1";
    "288-clear-internet-cache.ps1";
    "289-clear-temp-internet-files.ps1";
    "290-clear-edge-cache.ps1";
    "291-clear-chrome-cache.ps1";
    "292-clear-teams-classic-cache.ps1";
    "293-clear-teams-new-cache.ps1";
    "294-clear-office-file-cache.ps1";
    "295-clear-onedrive-logs-older-14-days.ps1";
    "296-clear-explorer-thumb-cache.ps1";
    "297-clear-crash-dumps-older-14-days.ps1";
    "298-clear-wer-archive-older-14-days.ps1";
    "299-clear-wer-queue-older-14-days.ps1";
    "300-clear-recent-items.ps1";
    "301-empty-recycle-bin.ps1";
    "302-open-disk-cleanup.ps1";
    "303-open-storage-settings.ps1";
    "304-open-troubleshoot-settings.ps1";
    "305-open-windows-update-settings.ps1";
    "306-open-network-status-settings.ps1";
    "307-open-proxy-settings.ps1";
    "308-open-vpn-settings.ps1";
    "309-open-wifi-settings.ps1";
    "310-open-bluetooth-settings.ps1";
    "311-open-default-apps-settings.ps1";
    "312-open-optional-features-settings.ps1";
    "313-open-apps-features-settings.ps1";
    "314-open-sync-settings.ps1";
    "315-open-signin-options.ps1";
    "316-open-work-access-settings.ps1";
    "317-open-onedrive-folder.ps1";
    "318-open-office-upload-center-cache-folder.ps1";
    "319-open-downloads-for-user-cleanup.ps1";
    "320-open-printmanagement-msc.ps1";
    "321-open-devices-printers-control.ps1";
    "322-open-printui-user.ps1";
    "323-run-wsreset.ps1";
    "324-restart-search-processes.ps1";
    "325-restart-startmenu-process.ps1";
    "326-restart-shell-experience.ps1";
    "327-restart-text-input-host.ps1";
    "328-restart-widgets.ps1";
    "329-restart-phone-link.ps1";
    "330-restart-snipping-tool.ps1";
    "331-restart-photos.ps1";
    "332-restart-acrobat.ps1";
    "333-restart-notepad.ps1";
    "334-restart-calculator.ps1";
    "335-ensure-evidence-root.ps1";
    "336-create-support-bundle-again.ps1";
    "337-open-evidence-root.ps1";
    "338-open-event-viewer.ps1";
    "339-open-reliability-monitor.ps1";
    "340-open-system-info.ps1"
)

$results=@()
foreach ($c in $checks) {
    $path = Join-Path $ScriptDir $c
    try {
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File $path -EvidenceRoot $ctx.RunDir
        $results += @{ check=$c; launched=$true; exit_code=$LASTEXITCODE }
    } catch {
        $results += @{ check=$c; launched=$false; exit_code=99; error=$_.Exception.Message }
    }
}

$failCount=@($results | Where-Object { $_.exit_code -eq 1 -or $_.launched -eq $false }).Count
$warnCount=@($results | Where-Object { $_.exit_code -eq 2 }).Count
$planCount=@($results | Where-Object { $_.exit_code -eq 0 }).Count

if ($failCount -gt 0) {
    Write-ItopsResult -Context $ctx -Result "FAIL" -Message "One or more self-fix dry-run plans failed to launch." -Data @{ checks=$results; plan_count=$planCount; fail_count=$failCount; warn_count=$warnCount } -ExitCode 1
} elseif ($warnCount -gt 0) {
    Write-ItopsResult -Context $ctx -Result "WARN" -Message "Self-fix dry-run plans completed with warnings." -Data @{ checks=$results; plan_count=$planCount; fail_count=$failCount; warn_count=$warnCount } -ExitCode 2
} else {
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "All self-fix candidates produced dry-run plans. No changes were applied." -Data @{ checks=$results; plan_count=$planCount; fail_count=$failCount; warn_count=$warnCount }
}
