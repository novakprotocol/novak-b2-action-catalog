# ENDUSER_RUN_ALL_NO_INPUT_CHECKS_V2
[CmdletBinding()]
param(
    [string]$EvidenceRoot = ""
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LibPath = Join-Path (Split-Path -Parent $ScriptDir) "lib\Common-SafeEvidence.ps1"
. $LibPath

$ctx = New-ItopsEvidenceContext -ActionId "ENDUSER_RUN_ALL_NO_INPUT_CHECKS_V2" -EvidenceRoot $EvidenceRoot

$checks = @(
    "26-Get-WindowsUptime.ps1",
    "27-Check-PendingRebootIndicators.ps1",
    "28-Get-DomainJoinSummary.ps1",
    "29-Check-TimeServiceStatus.ps1",
    "30-Check-DnsClientServiceStatus.ps1",
    "31-Check-WorkstationServiceStatus.ps1",
    "32-Check-WebClientServiceStatus.ps1",
    "33-Check-OfflineFilesServiceStatus.ps1",
    "34-Check-WindowsSearchServiceStatus.ps1",
    "35-Get-OneDriveNoPathSummary.ps1",
    "36-Get-KnownFoldersNoPathSummary.ps1",
    "37-Test-DocumentsFolderListable.ps1",
    "38-Test-DesktopFolderListable.ps1",
    "39-Test-DownloadsFolderListable.ps1",
    "40-Test-UserProfileFolderListable.ps1",
    "41-Get-DriveLetterSummary.ps1",
    "42-Check-LowLocalDiskSpace.ps1",
    "43-Get-RecycleBinNoNameSummary.ps1",
    "44-Check-LongPathsPolicy.ps1",
    "45-Get-PowerShellExecutionPolicySummary.ps1",
    "46-Get-FirewallProfileSummary.ps1",
    "47-Get-ProxyEnabledNoValueSummary.ps1",
    "48-Get-WinHttpProxyNoValueSummary.ps1",
    "49-Get-KerberosTicketCount.ps1",
    "50-Get-DnsCacheNoNameSummary.ps1",
    "51-Get-SmbMappingNoPathSummary.ps1",
    "52-Get-RecentNetworkErrorCount.ps1",
    "53-Get-RecentDiskNtfsErrorCount.ps1",
    "54-Get-RecentGroupPolicyErrorCount.ps1",
    "55-Get-SelfCheckEvidenceRootSummary.ps1",
    "56-Test-UserTempPathExists.ps1",
    "57-Get-StorageEnvironmentVariableSummary.ps1",
    "58-Get-CurrentUserGroupCount.ps1",
    "59-Get-RecentExplorerCrashCount.ps1"
)

$results = @()
foreach ($c in $checks) {
    $path = Join-Path $ScriptDir $c
    try {
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File $path -EvidenceRoot $ctx.RunDir
        $results += @{ check=$c; launched=$true; exit_code=$LASTEXITCODE }
    } catch {
        $results += @{ check=$c; launched=$false; error=$_.Exception.Message }
    }
}

$failCount = @($results | Where-Object { $_.exit_code -eq 1 -or $_.launched -eq $false }).Count
$warnCount = @($results | Where-Object { $_.exit_code -eq 2 }).Count

if ($failCount -gt 0) {
    Write-ItopsResult -Context $ctx -Result "FAIL" -Message "One or more no-input checks failed to launch or returned FAIL." -Data @{ checks=$results; fail_count=$failCount; warn_count=$warnCount } -ExitCode 1
} elseif ($warnCount -gt 0) {
    Write-ItopsResult -Context $ctx -Result "WARN" -Message "No-input checks completed with warnings." -Data @{ checks=$results; fail_count=$failCount; warn_count=$warnCount } -ExitCode 2
} else {
    Write-ItopsResult -Context $ctx -Result "PASS" -Message "All no-input checks completed with PASS." -Data @{ checks=$results; fail_count=$failCount; warn_count=$warnCount }
}
