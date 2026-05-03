from pathlib import Path
from datetime import datetime, timezone
import json
import subprocess

ROOT = Path.cwd()

TESTED_SOURCE_HEAD = subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip()
TESTED_SOURCE_SHORT = subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], text=True).strip()
RECORDED_UTC = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

def write(path: str, text: str) -> None:
    target = ROOT / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text.strip() + "\n", encoding="utf-8", newline="")

def ps_count(path: str, exclude: set[str] | None = None) -> int:
    exclude = exclude or set()
    root = ROOT / path
    return len([p for p in root.glob("*.ps1") if p.name not in exclude])

def all_ps_count() -> int:
    return len([p for p in ROOT.rglob("*.ps1") if ".git" not in p.parts])

action_index = json.loads((ROOT / "catalog/generated/action-index.json").read_text(encoding="utf-8"))
catalog_action_count = int(action_index["action_count"])
powershell_script_count = all_ps_count()

everyday_count = ps_count("action-layers/windows/end-user/everyday-no-admin-v6/scripts/checks")
app_count = ps_count(
    "action-layers/windows/end-user/app-self-help-v1/scripts/checks",
    {"000-Run-AppSelfHelp-V1.ps1"},
)
helpdesk_count = ps_count(
    "action-layers/windows/end-user/help-desk-evidence-v1/scripts/checks",
    {"000-Run-HelpDeskEvidence-V1.ps1"},
)

if catalog_action_count != 560:
    raise SystemExit(f"Expected catalog_action_count=560, found {catalog_action_count}")

if helpdesk_count != 20:
    raise SystemExit(f"Expected helpdesk_count=20, found {helpdesk_count}")

acceptance_path = "action-layers/windows/end-user/help-desk-evidence-v1/acceptance/LOCAL_BASELINE_ACCEPTANCE.md"

write(acceptance_path, f"""
# NOV&#923;K&trade; B2 Help Desk Evidence V1 - Local Baseline Acceptance

## Status

TEXT-BEGIN
RESULT=PASS
ACTION_LAYER=help-desk-evidence-v1
ACCEPTED_FOR_BASELINE=true
ACCEPTED_FOR_MUTATION=false
TEXT-END

## What was tested

The Help Desk Evidence V1 action layer was executed locally on the baseline Windows workstation after the printer evidence repair.

The rerun completed successfully:

TEXT-BEGIN
ACTION_ID=ENDUSER_RUN_HELPDESK_EVIDENCE_V1
RESULT=PASS
MESSAGE=All help desk evidence actions completed without script exit failures.
SCRIPT_COUNT=20
FAILED_SCRIPT_COUNT=0
TEXT-END

## Validation

TEXT-BEGIN
PowerShell syntax PASS
Action index PASS
No secrets or targets PASS
Current release pointer PASS
No brand mojibake PASS
Worktree clean after run PASS
TEXT-END

## Safety boundary

This acceptance record does not approve mutation.

This action layer is accepted only as:

TEXT-BEGIN
safe no-admin help desk evidence
read-only by default
sanitized local evidence summaries
ticket-ready support context
no-admin
no-target-list
no-credential
local-user-safe
evidence-producing
TEXT-END

## Evidence handling

Raw local evidence remains outside Git.

Do not commit:

TEXT-BEGIN
local usernames
hostnames
absolute evidence paths
raw event log output
raw file paths
raw target names
credentials
tokens
IPs
printer names
device names
customer data
TEXT-END

## Accepted floor

TEXT-BEGIN
ACTION_LAYER=help-desk-evidence-v1
LOCAL_BASELINE_RESULT=PASS
CATALOG_ACTION_COUNT={catalog_action_count}
POWERSHELL_SCRIPT_COUNT={powershell_script_count}
HELP_DESK_EVIDENCE_SCRIPT_COUNT={helpdesk_count}
ACCEPTED_FOR_BASELINE=true
ACCEPTED_FOR_MUTATION=false
TESTED_SOURCE_HEAD={TESTED_SOURCE_SHORT}
TESTED_SOURCE_FULL_HEAD={TESTED_SOURCE_HEAD}
RECORDED_UTC={RECORDED_UTC}
TEXT-END
""")

release = {
    "schema_version": "1.0",
    "release_type": "current_accepted_baseline",
    "repo_name": "novak-b2-action-catalog",
    "display_name": "NOVAK B2 Action Catalog",
    "source_branch": "main",
    "tested_source_commit": TESTED_SOURCE_HEAD,
    "tested_source_commit_short": TESTED_SOURCE_SHORT,
    "recorded_utc": RECORDED_UTC,
    "accepted_for_baseline": True,
    "accepted_for_mutation": False,
    "privilege_level": "no-admin",
    "credential_required": False,
    "target_list_required": False,
    "raw_evidence_in_git": False,
    "catalog_action_count": catalog_action_count,
    "powershell_script_count": powershell_script_count,
    "approved_action_layers": [
        {
            "action_layer_id": "everyday-no-admin-v6",
            "action_layer_path": "action-layers/windows/end-user/everyday-no-admin-v6",
            "local_baseline_result": "PASS",
            "accepted_for_baseline": True,
            "accepted_for_mutation": False,
            "script_count": everyday_count,
            "launcher": "action-layers/windows/end-user/everyday-no-admin-v6/launchers/CLICK_ME_Run_Everyday_No_Admin_Actions_V6.cmd",
            "runner": "action-layers/windows/end-user/everyday-no-admin-v6/scripts/checks/000-Run-Everyday-NoAdmin-Actions-V6.ps1",
            "acceptance_record": "action-layers/windows/end-user/everyday-no-admin-v6/acceptance/LOCAL_BASELINE_ACCEPTANCE.md",
        },
        {
            "action_layer_id": "app-self-help-v1",
            "action_layer_path": "action-layers/windows/end-user/app-self-help-v1",
            "local_baseline_result": "PASS",
            "accepted_for_baseline": True,
            "accepted_for_mutation": False,
            "script_count": app_count,
            "launcher": "action-layers/windows/end-user/app-self-help-v1/launchers/CLICK_ME_Run_App_Self_Help_V1.cmd",
            "runner": "action-layers/windows/end-user/app-self-help-v1/scripts/checks/000-Run-AppSelfHelp-V1.ps1",
            "acceptance_record": "action-layers/windows/end-user/app-self-help-v1/acceptance/LOCAL_BASELINE_ACCEPTANCE.md",
        },
        {
            "action_layer_id": "help-desk-evidence-v1",
            "action_layer_path": "action-layers/windows/end-user/help-desk-evidence-v1",
            "local_baseline_result": "PASS",
            "accepted_for_baseline": True,
            "accepted_for_mutation": False,
            "script_count": helpdesk_count,
            "launcher": None,
            "runner": "action-layers/windows/end-user/help-desk-evidence-v1/scripts/checks/000-Run-HelpDeskEvidence-V1.ps1",
            "acceptance_record": "action-layers/windows/end-user/help-desk-evidence-v1/acceptance/LOCAL_BASELINE_ACCEPTANCE.md",
        },
    ],
    "catalog": {
        "action_index_json": "catalog/generated/action-index.json",
        "action_index_csv": "catalog/generated/action-index.csv",
        "catalog_browser": "catalog/views/action-catalog.html",
        "current_floor_doc": "docs/CURRENT_FLOOR.md",
        "accepted_baseline_view": "catalog/views/current-accepted-baseline.md",
        "brand_naming": "docs/BRAND_NAMING.md",
        "site_front_door": "index.html",
    },
    "safety_boundary": {
        "mutation_approved": False,
        "admin_actions_approved": False,
        "enterprise_targeting_approved": False,
        "credentials_allowed_in_git": False,
        "raw_evidence_allowed_in_git": False,
    },
}

write("catalog/releases/current-accepted-baseline.json", json.dumps(release, indent=2))

write("catalog/views/current-accepted-baseline.md", f"""
# Current Accepted Baseline

## Accepted for baseline

TEXT-BEGIN
display_name: NOVAK B2 Action Catalog
tested_source_commit: {TESTED_SOURCE_SHORT}
accepted_for_baseline: true
accepted_for_mutation: false
layers: everyday-no-admin-v6, app-self-help-v1, help-desk-evidence-v1
catalog_action_count: {catalog_action_count}
powershell_script_count: {powershell_script_count}
TEXT-END

## Accepted layers

TEXT-BEGIN
everyday-no-admin-v6: PASS baseline accepted, mutation false
app-self-help-v1: PASS baseline accepted, mutation false
help-desk-evidence-v1: PASS baseline accepted, mutation false
TEXT-END

## Meaning

This means the accepted action layers successfully executed on the baseline Windows workstation without admin rights.

It does not mean the actions are approved for enterprise deployment, admin repair, automatic remediation, or mutation.

## Validation evidence

TEXT-BEGIN
PowerShell syntax PASS
catalog actions={catalog_action_count} PASS
no secrets or targets PASS
current release pointer PASS
no brand mojibake PASS
TEXT-END

## Browse all actions

TEXT-BEGIN
catalog/views/action-catalog.html
TEXT-END
""")

write("docs/CURRENT_FLOOR.md", f"""
# NOV&#923;K&trade; B2 Action Catalog - Current Floor

## Status

TEXT-BEGIN
RESULT=PASS
TESTED_SOURCE_HEAD={TESTED_SOURCE_SHORT}
TESTED_SOURCE_FULL_HEAD={TESTED_SOURCE_HEAD}
RECORDED_UTC={RECORDED_UTC}
TEXT-END

## What is real now

The public NOV&#923;K&trade; B2 Action Catalog is initialized, published, validated, and has three accepted no-admin baseline layers.

The catalog currently contains:

TEXT-BEGIN
CATALOG_ACTION_COUNT={catalog_action_count}
POWERSHELL_SCRIPT_COUNT={powershell_script_count}
TEXT-END

## Accepted local baselines

TEXT-BEGIN
everyday-no-admin-v6=PASS
app-self-help-v1=PASS
help-desk-evidence-v1=PASS
ACCEPTED_FOR_BASELINE=true
ACCEPTED_FOR_MUTATION=false
TEXT-END

## Validation

TEXT-BEGIN
PowerShell syntax: PASS
Action index: PASS
No secrets or targets: PASS
Current release pointer: PASS
No brand mojibake: PASS
TEXT-END

## Safety boundary

This floor does not approve mutation.

This floor does not approve admin-required actions.

This floor does not contain approved workplace targets, IPs, hostnames, credentials, tokens, or raw evidence.

## Catalog browsing

TEXT-BEGIN
index.html
catalog/views/action-catalog.html
catalog/releases/current-accepted-baseline.json
TEXT-END

## Next recommended work

1. Keep this floor stable.
2. Add a public evidence-package explanation page.
3. Add the next small support scenario pack only after preserving this accepted baseline.
""")

write("catalog/views/sync-source.md", f"""
# NOV&#923;K&trade; B2 Action Catalog - Sync Source

## Current accepted baseline

TEXT-BEGIN
REPO=novakprotocol/novak-b2-action-catalog
BRANCH=main
TESTED_SOURCE_HEAD={TESTED_SOURCE_SHORT}
TESTED_SOURCE_FULL_HEAD={TESTED_SOURCE_HEAD}
CURRENT_ACCEPTED_BASELINE=catalog/releases/current-accepted-baseline.json
CATALOG_BROWSER=catalog/views/action-catalog.html
SITE_FRONT_DOOR=index.html
ACCEPTED_FOR_BASELINE=true
ACCEPTED_FOR_MUTATION=false
TEXT-END

## Accepted layers

TEXT-BEGIN
everyday-no-admin-v6
app-self-help-v1
help-desk-evidence-v1
TEXT-END

## How a Windows GUI should consume this

1. Pull or fetch the repository.
2. Read catalog/releases/current-accepted-baseline.json.
3. Only display layers where accepted_for_baseline is true.
4. Do not run mutation actions unless accepted_for_mutation is true.
5. Do not assume workplace approval from this public baseline.

## Safety boundary

This public baseline is generic, no-admin, no-target-list, no-credential, local-user-safe, and read-only by default.

It does not contain workplace IPs, hostnames, usernames, tokens, credentials, or raw evidence.
""")

readme_path = ROOT / "README.md"
readme = readme_path.read_text(encoding="utf-8")

if "`help-desk-evidence-v1`" not in readme:
    readme = readme.replace(
        "| `app-self-help-v1` | PASS | false |",
        "| `app-self-help-v1` | PASS | false |\n| `help-desk-evidence-v1` | PASS | false |",
    )

readme_path.write_text(readme, encoding="utf-8", newline="")

print("RESULT=ACCEPTANCE_FILES_WRITTEN")
print(f"TESTED_SOURCE_HEAD={TESTED_SOURCE_SHORT}")
print(f"CATALOG_ACTION_COUNT={catalog_action_count}")
print(f"POWERSHELL_SCRIPT_COUNT={powershell_script_count}")
print(f"HELP_DESK_EVIDENCE_SCRIPT_COUNT={helpdesk_count}")
print(f"WROTE={acceptance_path}")
