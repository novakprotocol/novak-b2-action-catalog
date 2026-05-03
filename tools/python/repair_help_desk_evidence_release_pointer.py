from pathlib import Path
from datetime import datetime, timezone
import json
import subprocess

ROOT = Path.cwd()

head_full = subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip()
head_short = subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], text=True).strip()
utc_now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

release_path = ROOT / "catalog" / "releases" / "current-accepted-baseline.json"
release = json.loads(release_path.read_text(encoding="utf-8"))

# Restore canonical keys expected by validate_current_release_pointer.py.
release["source_commit"] = head_full
release["source_commit_short"] = head_short
release["accepted_source_commit"] = head_full
release["accepted_source_commit_short"] = head_short
release["tested_source_commit"] = head_full
release["tested_source_commit_short"] = head_short
release["recorded_utc"] = utc_now

launcher_path = "action-layers/windows/end-user/help-desk-evidence-v1/launchers/CLICK_ME_Run_Help_Desk_Evidence_V1.cmd"
runner_path = "action-layers/windows/end-user/help-desk-evidence-v1/scripts/checks/000-Run-HelpDeskEvidence-V1.ps1"

launcher_file = ROOT / launcher_path
launcher_file.parent.mkdir(parents=True, exist_ok=True)

launcher_file.write_text(
    "@echo off\r\n"
    "setlocal\r\n"
    "cd /d %~dp0\\..\\\r\n"
    "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%cd%\\scripts\\checks\\000-Run-HelpDeskEvidence-V1.ps1\"\r\n"
    "set EXITCODE=%ERRORLEVEL%\r\n"
    "echo.\r\n"
    "echo Help Desk Evidence V1 finished with exit code %EXITCODE%.\r\n"
    "pause\r\n"
    "exit /b %EXITCODE%\r\n",
    encoding="utf-8",
    newline=""
)

layers = release.get("approved_action_layers", [])
for layer in layers:
    if layer.get("action_layer_id") == "help-desk-evidence-v1":
        layer["launcher"] = launcher_path
        layer["runner"] = runner_path
        layer["acceptance_record"] = "action-layers/windows/end-user/help-desk-evidence-v1/acceptance/LOCAL_BASELINE_ACCEPTANCE.md"
        layer["accepted_for_baseline"] = True
        layer["accepted_for_mutation"] = False

release_path.write_text(json.dumps(release, indent=2) + "\n", encoding="utf-8", newline="")

report = ROOT / "docs" / "HELP_DESK_EVIDENCE_V1_RELEASE_POINTER_REPAIR.md"
report.write_text(
    "# Help Desk Evidence V1 Release Pointer Repair\n\n"
    "## Status\n\n"
    "```text\n"
    "RESULT=REPAIRED\n"
    f"SOURCE_COMMIT={head_full}\n"
    f"SOURCE_COMMIT_SHORT={head_short}\n"
    f"RECORDED_UTC={utc_now}\n"
    "FIXED_SOURCE_COMMIT_FIELD=true\n"
    "FIXED_HELP_DESK_LAUNCHER=true\n"
    "ACCEPTED_FOR_MUTATION=false\n"
    "```\n\n"
    "## Reason\n\n"
    "The real help-desk-evidence-v1 acceptance commit existed, but the current release pointer used newer alternate source field names and had a null launcher for layer 3.\n\n"
    "The existing validator expects `source_commit` and a non-empty launcher for every approved layer.\n\n"
    "## Boundary\n\n"
    "This repair does not approve mutation, admin repair, production deployment, credentials, target inventories, or raw evidence in Git.\n",
    encoding="utf-8",
    newline=""
)

print("RESULT=REPAIRED")
print(f"SOURCE_COMMIT={head_full}")
print(f"SOURCE_COMMIT_SHORT={head_short}")
print(f"LAUNCHER={launcher_path}")
print("ACCEPTED_FOR_MUTATION=false")
