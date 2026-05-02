#!/usr/bin/env python3
from pathlib import Path
from datetime import datetime, timezone
import json
import sys

ROOT = Path.cwd()
ACTION_INDEX = ROOT / "catalog" / "generated" / "action-index.json"
REPORT = ROOT / "docs" / "HELP_DESK_EVIDENCE_V1_CATALOG_REPAIR.md"

def find_action_lists(obj, path="$"):
    found = []

    if isinstance(obj, list):
        score = 0
        if obj and all(isinstance(item, dict) for item in obj):
            for item in obj:
                if "action_id" in item:
                    score += 3
                if "script_path" in item:
                    score += 3
                if "risk" in item:
                    score += 1
                if "status" in item:
                    score += 1
        if score:
            found.append((score, path, obj))

        for index, item in enumerate(obj):
            found.extend(find_action_lists(item, f"{path}[{index}]"))

    elif isinstance(obj, dict):
        for key, value in obj.items():
            found.extend(find_action_lists(value, f"{path}.{key}"))

    return found

if not ACTION_INDEX.exists():
    print(f"FAIL missing {ACTION_INDEX}")
    sys.exit(1)

data = json.loads(ACTION_INDEX.read_text(encoding="utf-8"))

candidates = find_action_lists(data)
if not candidates:
    print("FAIL could not find action list in action-index.json")
    sys.exit(1)

candidates.sort(key=lambda item: (item[0], len(item[2])), reverse=True)
score, action_path, actions = candidates[0]
actual_count = len(actions)

old_values = {}

for key in [
    "action_count",
    "actions_count",
    "total_actions",
    "catalog_action_count",
    "generated_action_count",
]:
    if isinstance(data, dict) and key in data:
        old_values[key] = data.get(key)
        data[key] = actual_count

if isinstance(data, dict):
    # The existing validator specifically complained about action_count,
    # so make sure it exists and is authoritative.
    if "action_count" not in data:
        old_values["action_count"] = "(missing)"
        data["action_count"] = actual_count

    data["updated_utc"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

ACTION_INDEX.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8", newline="")

lines = []
lines.append("# Help Desk Evidence V1 Catalog Repair")
lines.append("")
lines.append("## Status")
lines.append("")
lines.append("```text")
lines.append("RESULT=REPAIRED")
lines.append(f"ACTION_INDEX_SOURCE={action_path}")
lines.append(f"ACTUAL_ACTION_COUNT={actual_count}")
for key, value in old_values.items():
    lines.append(f"OLD_{key.upper()}={value}")
lines.append("```")
lines.append("")
lines.append("## Reason")
lines.append("")
lines.append("The help-desk-evidence-v1 candidate added 20 actions, increasing the generated action list from 540 to 560.")
lines.append("")
lines.append("The action list was present, but the top-level catalog count metadata needed to be updated to match the actual action list length.")
lines.append("")
lines.append("## Boundary")
lines.append("")
lines.append("This repair only updates catalog metadata. It does not accept the candidate layer for baseline and does not approve mutation.")
lines.append("")

REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="")

print("RESULT=REPAIRED")
print(f"ACTION_INDEX_SOURCE={action_path}")
print(f"ACTION_COUNT={actual_count}")
print(f"WROTE={REPORT.relative_to(ROOT)}")
