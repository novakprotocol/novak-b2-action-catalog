$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

. (Join-Path $PSScriptRoot "..\lib\Common-HelpDeskEvidenceV1.ps1")

$ActionId = "ENDUSER_HELPDESK_DISPLAY_SUMMARY_V1"
$Kind = "display_summary"

try {
    $Evidence = [ordered]@{}

    switch ($Kind) {
        "package_readiness" {
            $Evidence["package_mode"] = "local_ticket_ready_evidence"
            $Evidence["mutation_allowed"] = $false
            $Evidence["admin_required"] = $false
            $Evidence["raw_evidence_in_git"] = $false
        }

        "os_summary" {
            $Os = Get-CimInstance Win32_OperatingSystem
            $Evidence["caption_present"] = -not [string]::IsNullOrWhiteSpace([string]$Os.Caption)
            $Evidence["version_present"] = -not [string]::IsNullOrWhiteSpace([string]$Os.Version)
            $Evidence["build_present"] = -not [string]::IsNullOrWhiteSpace([string]$Os.BuildNumber)
            $Evidence["architecture_present"] = -not [string]::IsNullOrWhiteSpace([string]$Os.OSArchitecture)
        }

        "uptime_bucket" {
            $Os = Get-CimInstance Win32_OperatingSystem
            $LastBoot = $Os.LastBootUpTime
            $Hours = [int]((Get-Date) - $LastBoot).TotalHours
            $Bucket = if ($Hours -lt 8) { "lt_8h" } elseif ($Hours -lt 24) { "lt_24h" } elseif ($Hours -lt 168) { "lt_7d" } else { "gte_7d" }
            $Evidence["uptime_bucket"] = $Bucket
        }

        "system_drive_space" {
            $Disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
            if ($null -ne $Disk) {
                $SizeGb = [math]::Round(($Disk.Size / 1GB), 1)
                $FreeGb = [math]::Round(($Disk.FreeSpace / 1GB), 1)
                $FreePercent = if ($Disk.Size -gt 0) { [math]::Round(($Disk.FreeSpace / $Disk.Size) * 100, 1) } else { -1 }
                $Evidence["system_drive_size_gb_rounded"] = $SizeGb
                $Evidence["system_drive_free_gb_rounded"] = $FreeGb
                $Evidence["system_drive_free_percent_rounded"] = $FreePercent
            } else {
                $Evidence["system_drive_present"] = $false
            }
        }

        "memory_summary" {
            $Os = Get-CimInstance Win32_OperatingSystem
            $Evidence["total_memory_gb_rounded"] = [math]::Round(($Os.TotalVisibleMemorySize / 1MB), 1)
            $Evidence["free_memory_gb_rounded"] = [math]::Round(($Os.FreePhysicalMemory / 1MB), 1)
        }

        "core_services" {
            $Evidence["bits"] = Get-ServiceStateSafe -Name "BITS"
            $Evidence["eventlog"] = Get-ServiceStateSafe -Name "EventLog"
            $Evidence["lanmanworkstation"] = Get-ServiceStateSafe -Name "LanmanWorkstation"
            $Evidence["wsearch"] = Get-ServiceStateSafe -Name "WSearch"
        }

        "network_adapters" {
            $Adapters = @(Get-NetAdapter -ErrorAction SilentlyContinue)
            $Evidence["adapter_count"] = $Adapters.Count
            $Evidence["up_count"] = @($Adapters | Where-Object { $_.Status -eq "Up" }).Count
            $Evidence["down_count"] = @($Adapters | Where-Object { $_.Status -eq "Down" }).Count
        }

        "dns_client" {
            $Evidence["dnscache"] = Get-ServiceStateSafe -Name "Dnscache"
        }

        "printer_summary" {
            $Printers = @(Get-Printer -ErrorAction SilentlyContinue)
            $Evidence["printer_count"] = $Printers.Count
            $Evidence["default_printer_present"] = @($Printers | Where-Object { $_.Default -eq $true }).Count -gt 0
        }

        "display_summary" {
            $Displays = @(Get-CimInstance Win32_DesktopMonitor -ErrorAction SilentlyContinue)
            $Evidence["display_count"] = $Displays.Count
        }

        "device_problem_count" {
            $Devices = @(Get-PnpDevice -ErrorAction SilentlyContinue)
            $Evidence["device_count"] = $Devices.Count
            $Evidence["problem_count"] = @($Devices | Where-Object { $_.Status -notin @("OK", "Unknown") }).Count
        }

        "app_error_count_24h" {
            $Evidence["application_error_count_24h"] = Get-EventCountSafe -LogName "Application" -Hours 24 -Level 2
        }

        "system_error_count_24h" {
            $Evidence["system_error_count_24h"] = Get-EventCountSafe -LogName "System" -Hours 24 -Level 2
        }

        "windows_update" {
            $Evidence["wuauserv"] = Get-ServiceStateSafe -Name "wuauserv"
            $Evidence["bits"] = Get-ServiceStateSafe -Name "BITS"
        }

        "office_processes" {
            $Evidence["office_process_counts"] = Get-ProcessCountSafe -Names @("winword", "excel", "powerpnt", "outlook", "onenote")
        }

        "onedrive_summary" {
            $Evidence["onedrive_process_count"] = @(Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue).Count
            $Evidence["onedrive_env_present"] = [bool]($env:OneDrive)
        }

        "teams_summary" {
            $Evidence["teams_process_count"] = @(Get-Process -Name "ms-teams", "Teams" -ErrorAction SilentlyContinue).Count
        }

        "browser_processes" {
            $Evidence["browser_process_counts"] = Get-ProcessCountSafe -Names @("msedge", "chrome", "firefox")
        }

        "evidence_root" {
            $Root = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "NOVAK-B2-Windows-SelfCheck"
            $Evidence["evidence_root_present"] = Test-Path $Root
            if (Test-Path $Root) {
                $Evidence["evidence_package_count"] = @(Get-ChildItem -Path $Root -Directory -ErrorAction SilentlyContinue).Count
            } else {
                $Evidence["evidence_package_count"] = 0
            }
        }

        "ticket_package_plan" {
            $Evidence["ticket_package_includes_sanitized_summaries"] = $true
            $Evidence["ticket_package_excludes_raw_logs"] = $true
            $Evidence["ticket_package_excludes_credentials"] = $true
            $Evidence["ticket_package_excludes_target_inventory"] = $true
            $Evidence["mutation_allowed"] = $false
        }

        default {
            $Evidence["unknown_kind"] = $Kind
        }
    }

    Write-HelpDeskEvidenceResult -ActionId $ActionId -Result "PASS" -Message "Collected sanitized help desk evidence summary without changing the system." -Evidence $Evidence
}
catch {
    $Evidence = [ordered]@{
        error_type = $_.Exception.GetType().FullName
        sanitized = $true
    }

    Write-HelpDeskEvidenceResult -ActionId $ActionId -Result "FAIL" -Message "Help desk evidence action failed before completion; error detail was sanitized." -Evidence $Evidence
    exit 1
}
