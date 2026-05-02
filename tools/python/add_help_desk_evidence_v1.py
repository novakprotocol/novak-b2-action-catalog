#!/usr/bin/env python3
from __future__ import annotations

from copy import deepcopy
from pathlib import Path
from datetime import datetime, timezone
import csv
import hashlib
import json
import sys

ROOT = Path.cwd()

LAYER_ID = "help-desk-evidence-v1"
LAYER_PATH = "action-layers/windows/end-user/help-desk-evidence-v1"
CHECKS_PATH = ROOT / LAYER_PATH / "scripts" / "checks"
LIB_PATH = ROOT / LAYER_PATH / "scripts" / "lib"
MANIFEST_JSON = ROOT / LAYER_PATH / "manifest.help-desk-evidence-v1.json"
MANIFEST_CSV = ROOT / LAYER_PATH / "manifest.help-desk-evidence-v1.csv"
README = ROOT / LAYER_PATH / "README.md"
DOC = ROOT / "docs" / "HELP_DESK_EVIDENCE_V1_CANDIDATE.md"
ACTION_INDEX = ROOT / "catalog" / "generated" / "action-index.json"

ACTIONS = [
    ("541-helpdesk-package-readiness.ps1", "ENDUSER_HELPDESK_PACKAGE_READINESS_V1", "Help desk package readiness", "Records readiness for local ticket-ready evidence packaging.", "Evidence package", "Help desk evidence", "package_readiness"),
    ("542-helpdesk-os-version-summary.ps1", "ENDUSER_HELPDESK_OS_VERSION_SUMMARY_V1", "OS version summary", "Collects Windows version and build presence without recording device identity.", "Evidence summary", "Windows", "os_summary"),
    ("543-helpdesk-uptime-bucket.ps1", "ENDUSER_HELPDESK_UPTIME_BUCKET_V1", "Uptime bucket", "Collects an uptime bucket without recording usernames or hostnames.", "Evidence summary", "Windows", "uptime_bucket"),
    ("544-helpdesk-system-drive-space-summary.ps1", "ENDUSER_HELPDESK_SYSTEM_DRIVE_SPACE_SUMMARY_V1", "System drive space summary", "Collects rounded system drive capacity and free-space summary.", "Evidence summary", "Storage", "system_drive_space"),
    ("545-helpdesk-memory-summary.ps1", "ENDUSER_HELPDESK_MEMORY_SUMMARY_V1", "Memory summary", "Collects rounded memory capacity and available-memory summary.", "Evidence summary", "Performance", "memory_summary"),
    ("546-helpdesk-core-service-status-summary.ps1", "ENDUSER_HELPDESK_CORE_SERVICE_STATUS_SUMMARY_V1", "Core service status summary", "Collects selected Windows service states without changing services.", "Evidence summary", "Services", "core_services"),
    ("547-helpdesk-network-adapter-status-summary.ps1", "ENDUSER_HELPDESK_NETWORK_ADAPTER_STATUS_SUMMARY_V1", "Network adapter status summary", "Counts adapter status groups without collecting IP or MAC values.", "Evidence summary", "Network", "network_adapters"),
    ("548-helpdesk-dns-client-status.ps1", "ENDUSER_HELPDESK_DNS_CLIENT_STATUS_V1", "DNS client status", "Collects DNS Client service status without changing services.", "Evidence summary", "Network", "dns_client"),
    ("549-helpdesk-printer-summary.ps1", "ENDUSER_HELPDESK_PRINTER_SUMMARY_V1", "Printer summary", "Counts printer presence without recording printer names.", "Evidence summary", "Printers", "printer_summary"),
    ("550-helpdesk-display-summary.ps1", "ENDUSER_HELPDESK_DISPLAY_SUMMARY_V1", "Display summary", "Counts display/monitor presence without recording device identifiers.", "Evidence summary", "Display", "display_summary"),
    ("551-helpdesk-device-problem-count.ps1", "ENDUSER_HELPDESK_DEVICE_PROBLEM_COUNT_V1", "Device problem count", "Counts device problem states without listing device names.", "Evidence summary", "Devices", "device_problem_count"),
    ("552-helpdesk-app-error-count-24h.ps1", "ENDUSER_HELPDESK_APP_ERROR_COUNT_24H_V1", "Application error count 24h", "Counts recent Application log errors without collecting raw event text.", "Evidence summary", "Events", "app_error_count_24h"),
    ("553-helpdesk-system-error-count-24h.ps1", "ENDUSER_HELPDESK_SYSTEM_ERROR_COUNT_24H_V1", "System error count 24h", "Counts recent System log errors without collecting raw event text.", "Evidence summary", "Events", "system_error_count_24h"),
    ("554-helpdesk-windows-update-service-summary.ps1", "ENDUSER_HELPDESK_WINDOWS_UPDATE_SERVICE_SUMMARY_V1", "Windows Update service summary", "Collects Windows Update service status without changing services.", "Evidence summary", "Windows Update", "windows_update"),
    ("555-helpdesk-office-process-summary.ps1", "ENDUSER_HELPDESK_OFFICE_PROCESS_SUMMARY_V1", "Office process summary", "Counts selected Office process presence without reading document content.", "Evidence summary", "Office", "office_processes"),
    ("556-helpdesk-onedrive-summary.ps1", "ENDUSER_HELPDESK_ONEDRIVE_SUMMARY_V1", "OneDrive summary", "Counts OneDrive process presence and sync-root environment presence without values.", "Evidence summary", "OneDrive", "onedrive_summary"),
    ("557-helpdesk-teams-summary.ps1", "ENDUSER_HELPDESK_TEAMS_SUMMARY_V1", "Teams summary", "Counts Teams process presence without reading app content.", "Evidence summary", "Teams", "teams_summary"),
    ("558-helpdesk-browser-process-summary.ps1", "ENDUSER_HELPDESK_BROWSER_PROCESS_SUMMARY_V1", "Browser process summary", "Counts selected browser processes without reading browsing content.", "Evidence summary", "Browsers", "browser_processes"),
    ("559-helpdesk-evidence-root-summary.ps1", "ENDUSER_HELPDESK_EVIDENCE_ROOT_SUMMARY_V1", "Evidence root summary", "Counts local evidence package roots without listing names.", "Evidence summary", "Support evidence", "evidence_root"),
    ("560-helpdesk-ticket-package-plan.ps1", "ENDUSER_HELPDESK_TICKET_PACKAGE_PLAN_V1", "Ticket package plan", "Records plan-only ticket package guidance without changing the system.", "Plan-only guidance", "Help desk evidence", "ticket_package_plan"),
]

COMMON = r'''
function New-HelpDeskEvidenceRoot {
    param([string]$ActionId)

    $Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $SafeAction = $ActionId -replace '[^A-Za-z0-9_\-]', '_'
    $Root = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "NOVAK-B2-Windows-SelfCheck"
    $RunRoot = Join-Path $Root "$Stamp-$SafeAction"

    New-Item -ItemType Directory -Force -Path $RunRoot | Out-Null
    return $RunRoot
}

function Write-HelpDeskEvidenceResult {
    param(
        [string]$ActionId,
        [string]$Result,
        [string]$Message,
        [hashtable]$Evidence
    )

    $RunRoot = New-HelpDeskEvidenceRoot -ActionId $ActionId
    $JsonPath = Join-Path $RunRoot "result.json"
    $TextPath = Join-Path $RunRoot "result.txt"

    $Payload = [ordered]@{
        action_id = $ActionId
        result = $Result
        message = $Message
        collected_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        safety_boundary = [ordered]@{
            no_admin_required = $true
            mutation_performed = $false
            raw_event_text_collected = $false
            raw_file_paths_collected = $false
            credential_collection_allowed = $false
            target_inventory_collection_allowed = $false
        }
        evidence = $Evidence
    }

    $Payload | ConvertTo-Json -Depth 12 | Set-Content -Encoding UTF8 -Path $JsonPath

    @(
        "ACTION_ID=$ActionId",
        "RESULT=$Result",
        "MESSAGE=$Message",
        "EVIDENCE_JSON=$JsonPath",
        "EVIDENCE_TEXT=$TextPath"
    ) | Set-Content -Encoding UTF8 -Path $TextPath

    Write-Host "ACTION_ID=$ActionId"
    Write-Host "RESULT=$Result"
    Write-Host "MESSAGE=$Message"
    Write-Host "EVIDENCE_JSON=$JsonPath"
    Write-Host "EVIDENCE_TEXT=$TextPath"
}

function Get-ServiceStateSafe {
    param([string]$Name)

    $Svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $Svc) {
        return "not_found"
    }

    return [string]$Svc.Status
}

function Get-ProcessCountSafe {
    param([string[]]$Names)

    $Result = [ordered]@{}
    foreach ($Name in $Names) {
        $Result[$Name] = @(Get-Process -Name $Name -ErrorAction SilentlyContinue).Count
    }
    return $Result
}

function Get-EventCountSafe {
    param(
        [string]$LogName,
        [int]$Hours,
        [int]$Level
    )

    $StartTime = (Get-Date).AddHours(-1 * $Hours)

    try {
        $Events = Get-WinEvent -FilterHashtable @{
            LogName = $LogName
            StartTime = $StartTime
            Level = $Level
        } -ErrorAction Stop

        return @($Events).Count
    }
    catch {
        return -1
    }
}
'''.strip()

SCRIPT_TEMPLATE = r'''
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

. (Join-Path $PSScriptRoot "..\lib\Common-HelpDeskEvidenceV1.ps1")

$ActionId = "__ACTION_ID__"
$Kind = "__KIND__"

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
'''.strip()

RUNNER = r'''
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$Start = Get-Date
function Step {
    param([string]$Message)
    $Elapsed = [int]((Get-Date) - $Start).TotalSeconds
    Write-Host ""
    Write-Host "===== $Message | elapsed=${Elapsed}s ====="
}

Step "00 :: DISCOVER HELP DESK EVIDENCE ACTIONS"

$Scripts = Get-ChildItem -Path $PSScriptRoot -Filter "*.ps1" -File |
    Where-Object { $_.Name -ne "000-Run-HelpDeskEvidence-V1.ps1" } |
    Sort-Object Name

Write-Host "SCRIPT_COUNT=$($Scripts.Count)"

$Failed = 0
$Index = 0

foreach ($Script in $Scripts) {
    $Index++
    Step ("RUN {0}/{1} :: {2}" -f $Index, $Scripts.Count, $Script.Name)

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Script.FullName
    if ($LASTEXITCODE -ne 0) {
        $Failed++
        Write-Host "SCRIPT_RESULT=FAIL"
    } else {
        Write-Host "SCRIPT_RESULT=PASS"
    }
}

Step "FINAL :: HELP DESK EVIDENCE RUN SUMMARY"

Write-Host "ACTION_ID=ENDUSER_RUN_HELPDESK_EVIDENCE_V1"
if ($Failed -eq 0) {
    Write-Host "RESULT=PASS"
    Write-Host "MESSAGE=All help desk evidence actions completed without script exit failures."
    exit 0
}

Write-Host "RESULT=FAIL"
Write-Host "FAILED_SCRIPT_COUNT=$Failed"
exit 1
'''.strip()

def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def write(path: Path, text: str):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text + "\n", encoding="utf-8", newline="")

def load_index():
    return json.loads(ACTION_INDEX.read_text(encoding="utf-8"))

def find_template(actions):
    for action in actions:
        if isinstance(action, dict) and "action_id" in action and "script_path" in action:
            return action
    raise SystemExit("Could not find action template with action_id and script_path")

def update_record(template, filename, action_id, name, description, action_type, issue_area, kind):
    script_path = f"{LAYER_PATH}/scripts/checks/{filename}"
    record = deepcopy(template)

    updates = {
        "action_id": action_id,
        "name": name,
        "description": description,
        "action_type": action_type,
        "issue_area": issue_area,
        "risk": "low",
        "risk_tier": "low",
        "status": "candidate",
        "action_layer": LAYER_PATH,
        "action_layer_id": LAYER_ID,
        "layer": LAYER_PATH,
        "action_layer_path": LAYER_PATH,
        "script_path": script_path,
    }

    for key, value in updates.items():
        if key in record or key in {"action_id", "name", "description", "action_type", "issue_area", "risk", "status", "action_layer", "script_path"}:
            record[key] = value

    false_keys = [
        "admin_required",
        "requires_admin",
        "runtime_input_required",
        "input_required",
        "requires_input",
        "mutation_possible",
        "can_mutate",
        "apply_required",
        "requires_apply",
    ]

    true_keys = [
        "no_admin",
        "no_input",
        "local_user_safe",
        "read_only",
    ]

    for key in false_keys:
        if key in record:
            record[key] = False

    for key in true_keys:
        if key in record:
            record[key] = True

    full_script_path = ROOT / script_path
    digest = sha256_file(full_script_path)

    for key in ["script_sha256", "sha256", "script_hash", "hash"]:
        if key in record:
            record[key] = digest

    return record

def main():
    CHECKS_PATH.mkdir(parents=True, exist_ok=True)
    LIB_PATH.mkdir(parents=True, exist_ok=True)

    write(LIB_PATH / "Common-HelpDeskEvidenceV1.ps1", COMMON)
    write(CHECKS_PATH / "000-Run-HelpDeskEvidence-V1.ps1", RUNNER)

    for filename, action_id, name, description, action_type, issue_area, kind in ACTIONS:
        script = SCRIPT_TEMPLATE.replace("__ACTION_ID__", action_id).replace("__KIND__", kind)
        write(CHECKS_PATH / filename, script)

    data = load_index()
    actions = data.get("actions")
    if not isinstance(actions, list):
        raise SystemExit("catalog/generated/action-index.json does not contain an actions list")

    template = find_template(actions)
    existing_by_id = {item.get("action_id"): item for item in actions if isinstance(item, dict)}

    new_records = []
    for item in ACTIONS:
        record = update_record(template, *item)
        new_records.append(record)

        if record["action_id"] in existing_by_id:
            existing_by_id[record["action_id"]].update(record)
        else:
            actions.append(record)

    ACTION_INDEX.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8", newline="")

    MANIFEST_JSON.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_JSON.write_text(json.dumps(new_records, indent=2) + "\n", encoding="utf-8", newline="")

    fieldnames = list(new_records[0].keys())
    with MANIFEST_CSV.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        for record in new_records:
            writer.writerow(record)

    readme = [
        "# NOV&#923;K&trade; B2 Help Desk Evidence V1",
        "",
        "Candidate action layer for sanitized, local, ticket-ready help desk evidence packaging.",
        "",
        "## Boundary",
        "",
        "```text",
        "MUTATION_ALLOWED=false",
        "ADMIN_REQUIRED=false",
        "RAW_EVENT_TEXT_COLLECTED=false",
        "RAW_FILE_PATHS_COLLECTED=false",
        "CREDENTIAL_COLLECTION_ALLOWED=false",
        "TARGET_INVENTORY_COLLECTION_ALLOWED=false",
        "```",
        "",
        "## Runner",
        "",
        "```powershell",
        "powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\\action-layers\\windows\\end-user\\help-desk-evidence-v1\\scripts\\checks\\000-Run-HelpDeskEvidence-V1.ps1",
        "```",
        "",
    ]
    write(README, "\n".join(readme))

    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    doc = [
        "# Help Desk Evidence V1 Candidate",
        "",
        "## Status",
        "",
        "```text",
        "RESULT=CANDIDATE_CREATED",
        f"RECORDED_UTC={now}",
        "ACTION_LAYER=help-desk-evidence-v1",
        f"ACTION_COUNT={len(ACTIONS)}",
        "ACCEPTED_FOR_BASELINE=false",
        "ACCEPTED_FOR_MUTATION=false",
        "```",
        "",
        "## Purpose",
        "",
        "Create sanitized, local, ticket-ready evidence summaries that help a help desk understand the issue faster.",
        "",
        "## Boundary",
        "",
        "This candidate does not approve mutation, admin repair, production deployment, remote collection, target inventories, raw logs, credentials, or automatic remediation.",
        "",
        "## Next acceptance step",
        "",
        "Run the layer locally, verify the repository remains clean, validate all catalogs, and only then write an acceptance record.",
        "",
    ]
    write(DOC, "\n".join(doc))

    print(f"HELP_DESK_EVIDENCE_V1_ACTIONS={len(ACTIONS)}")
    print(f"WROTE={LAYER_PATH}")
    print(f"WROTE={DOC.relative_to(ROOT)}")
    print(f"UPDATED=catalog/generated/action-index.json")

if __name__ == "__main__":
    main()
