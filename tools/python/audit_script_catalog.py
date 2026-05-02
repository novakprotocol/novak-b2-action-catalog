#!/usr/bin/env python3
from __future__ import annotations

from collections import Counter, defaultdict
from pathlib import Path
import json
import re
import sys
from datetime import datetime, timezone

ROOT = Path.cwd()
ACTION_INDEX = ROOT / "catalog" / "generated" / "action-index.json"
REPORT = ROOT / "docs" / "SCRIPT_CATALOG_AUDIT_V1.md"

TEXT_EXTENSIONS = {".ps1"}
RISK_PATTERNS = [
    "Remove-Item",
    "Set-ItemProperty",
    "New-ItemProperty",
    "Remove-ItemProperty",
    "Stop-Service",
    "Start-Service",
    "Restart-Service",
    "Set-Service",
    "Disable-",
    "Enable-",
    "Restart-Computer",
    "Stop-Computer",
    "format.com",
    "Format-Volume",
    "Clear-",
    "Invoke-WebRequest",
    "Invoke-RestMethod",
    "net user",
    "net localgroup",
    "reg add",
    "reg delete",
    "schtasks",
    "Start-BitsTransfer",
]

def rel(path: Path) -> str:
    return str(path.relative_to(ROOT)).replace("\\", "/")

def norm(value: str) -> str:
    return value.replace("\\", "/").strip().lower()

def load_json(path: Path):
    if not path.exists():
        raise SystemExit(f"Missing action index: {path}")
    return json.loads(path.read_text(encoding="utf-8"))

def score_action_list(value):
    if not isinstance(value, list) or not value:
        return 0
    if not all(isinstance(item, dict) for item in value):
        return 0

    score = 0
    for item in value:
        if "action_id" in item:
            score += 3
        if "script_path" in item:
            score += 3
        if "risk" in item:
            score += 1
        if "status" in item:
            score += 1
        if "action_layer" in item or "action_layer_path" in item or "layer" in item:
            score += 1
    return score

def find_action_lists(obj, path="$"):
    found = []

    if isinstance(obj, list):
        score = score_action_list(obj)
        if score:
            found.append((score, path, obj))
        for index, item in enumerate(obj):
            found.extend(find_action_lists(item, f"{path}[{index}]"))

    elif isinstance(obj, dict):
        for key, value in obj.items():
            found.extend(find_action_lists(value, f"{path}.{key}"))

    return found

def extract_actions(data):
    candidates = find_action_lists(data)
    if not candidates:
        raise SystemExit("Could not find an action list in catalog/generated/action-index.json")

    candidates.sort(key=lambda item: (item[0], len(item[2])), reverse=True)
    score, path, actions = candidates[0]
    return path, actions

def get_field(action, names, default=""):
    for name in names:
        value = action.get(name)
        if value is not None and str(value).strip():
            return str(value).strip()
    return default

def classify_script(path: Path, indexed_paths: set[str]) -> str:
    r = norm(rel(path))
    name = path.name.lower()

    if r in indexed_paths:
        return "cataloged"
    if r.startswith("tools/"):
        return "tool"
    if name.startswith("000-run-"):
        return "runner"
    if "/scripts/lib/" in r:
        return "library"
    if "/" not in r and (name.startswith("bootstrap-") or name.startswith("repair-")):
        return "root_operator"
    return "unindexed"

def find_risk_hits(script_paths):
    hits = []

    for path in script_paths:
        try:
            lines = path.read_text(encoding="utf-8").splitlines()
        except UnicodeDecodeError:
            continue

        for line_no, line in enumerate(lines, start=1):
            for pattern in RISK_PATTERNS:
                if re.search(re.escape(pattern), line, re.IGNORECASE):
                    hits.append({
                        "script": rel(path),
                        "line": line_no,
                        "pattern": pattern,
                        "text": line.strip()[:180],
                    })

    return hits

def markdown_table(rows, headers):
    out = []
    out.append("| " + " | ".join(headers) + " |")
    out.append("|" + "|".join(["---"] * len(headers)) + "|")
    for row in rows:
        out.append("| " + " | ".join(str(row.get(h, "")) for h in headers) + " |")
    return "\n".join(out)

def main():
    data = load_json(ACTION_INDEX)
    action_source_path, actions = extract_actions(data)

    ps_scripts = [
        p for p in ROOT.rglob("*.ps1")
        if ".git" not in p.parts
    ]

    action_ids = []
    indexed_script_paths = set()
    missing_script_refs = []
    empty_script_refs = []

    by_layer = Counter()
    by_risk = Counter()
    by_status = Counter()

    for action in actions:
        action_id = get_field(action, ["action_id"], "(missing-action-id)")
        action_ids.append(action_id)

        script_path = get_field(action, ["script_path", "script", "path"])
        layer = get_field(action, ["action_layer", "action_layer_id", "layer", "action_layer_path"], "(missing-layer)")
        risk = get_field(action, ["risk", "risk_tier"], "(missing-risk)")
        status = get_field(action, ["status"], "(missing-status)")

        by_layer[layer] += 1
        by_risk[risk] += 1
        by_status[status] += 1

        if not script_path:
            empty_script_refs.append(action_id)
            continue

        indexed_script_paths.add(norm(script_path))

        if not (ROOT / script_path).exists():
            missing_script_refs.append({
                "action_id": action_id,
                "script_path": script_path,
            })

    duplicate_ids = sorted([
        action_id for action_id, count in Counter(action_ids).items()
        if count > 1
    ])

    script_classes = Counter()
    scripts_by_class = defaultdict(list)

    for script in ps_scripts:
        cls = classify_script(script, indexed_script_paths)
        script_classes[cls] += 1
        scripts_by_class[cls].append(rel(script))

    risk_hits = find_risk_hits(ps_scripts)

    hard_failures = []
    if missing_script_refs:
        hard_failures.append(f"missing_script_refs={len(missing_script_refs)}")
    if empty_script_refs:
        hard_failures.append(f"empty_script_refs={len(empty_script_refs)}")
    if duplicate_ids:
        hard_failures.append(f"duplicate_action_ids={len(duplicate_ids)}")

    result = "PASS" if not hard_failures else "FAIL"
    if result == "PASS" and risk_hits:
        result = "PASS_WITH_REVIEW_ITEMS"

    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    lines = []
    lines.append("# Script Catalog Audit V1")
    lines.append("")
    lines.append("## Status")
    lines.append("")
    lines.append("```text")
    lines.append(f"RESULT={result}")
    lines.append(f"RECORDED_UTC={now}")
    lines.append(f"ACTION_INDEX_SOURCE={action_source_path}")
    lines.append(f"ACTION_COUNT={len(actions)}")
    lines.append(f"POWERSHELL_SCRIPT_COUNT={len(ps_scripts)}")
    lines.append(f"MISSING_SCRIPT_REF_COUNT={len(missing_script_refs)}")
    lines.append(f"EMPTY_SCRIPT_REF_COUNT={len(empty_script_refs)}")
    lines.append(f"DUPLICATE_ACTION_ID_COUNT={len(duplicate_ids)}")
    lines.append(f"RISK_PATTERN_HIT_COUNT={len(risk_hits)}")
    lines.append("```")
    lines.append("")
    lines.append("## Action counts by layer")
    lines.append("")
    layer_rows = [{"Layer": k, "Count": v} for k, v in sorted(by_layer.items())]
    lines.append(markdown_table(layer_rows, ["Layer", "Count"]))
    lines.append("")
    lines.append("## Action counts by risk")
    lines.append("")
    risk_rows = [{"Risk": k, "Count": v} for k, v in sorted(by_risk.items())]
    lines.append(markdown_table(risk_rows, ["Risk", "Count"]))
    lines.append("")
    lines.append("## Action counts by status")
    lines.append("")
    status_rows = [{"Status": k, "Count": v} for k, v in sorted(by_status.items())]
    lines.append(markdown_table(status_rows, ["Status", "Count"]))
    lines.append("")
    lines.append("## PowerShell script classification")
    lines.append("")
    class_rows = [{"Class": k, "Count": v} for k, v in sorted(script_classes.items())]
    lines.append(markdown_table(class_rows, ["Class", "Count"]))
    lines.append("")
    lines.append("## Missing or empty script references")
    lines.append("")
    if not missing_script_refs and not empty_script_refs:
        lines.append("```text")
        lines.append("MISSING_OR_EMPTY_SCRIPT_REFERENCES=0")
        lines.append("```")
    else:
        lines.append("### Empty script references")
        lines.append("")
        for action_id in empty_script_refs[:100]:
            lines.append(f"- `{action_id}`")
        lines.append("")
        lines.append("### Missing script references")
        lines.append("")
        for item in missing_script_refs[:100]:
            lines.append(f"- `{item['action_id']}` -> `{item['script_path']}`")
    lines.append("")
    lines.append("## Duplicate action IDs")
    lines.append("")
    if not duplicate_ids:
        lines.append("```text")
        lines.append("DUPLICATE_ACTION_IDS=0")
        lines.append("```")
    else:
        for action_id in duplicate_ids[:100]:
            lines.append(f"- `{action_id}`")
    lines.append("")
    lines.append("## Unindexed scripts")
    lines.append("")
    unindexed = scripts_by_class.get("unindexed", [])
    lines.append("These are PowerShell scripts that are not referenced by the action index and are not classified as tools, runners, libraries, or root operator scripts.")
    lines.append("")
    if not unindexed:
        lines.append("```text")
        lines.append("UNINDEXED_SCRIPT_COUNT=0")
        lines.append("```")
    else:
        lines.append(f"```text\nUNINDEXED_SCRIPT_COUNT={len(unindexed)}\n```")
        for item in unindexed[:100]:
            lines.append(f"- `{item}`")
    lines.append("")
    lines.append("## Risk-pattern review hits")
    lines.append("")
    lines.append("These are string-pattern hits only. They are review items, not automatic proof of unsafe behavior.")
    lines.append("")
    if not risk_hits:
        lines.append("```text")
        lines.append("RISK_PATTERN_HIT_COUNT=0")
        lines.append("```")
    else:
        lines.append(f"```text\nRISK_PATTERN_HIT_COUNT={len(risk_hits)}\n```")
        for hit in risk_hits[:100]:
            safe_text = hit["text"].replace("|", "\\|")
            lines.append(f"- `{hit['script']}:{hit['line']}` pattern=`{hit['pattern']}` text=`{safe_text}`")
    lines.append("")
    lines.append("## Interpretation")
    lines.append("")
    lines.append("- `cataloged` scripts are referenced by the generated action index.")
    lines.append("- `runner` scripts are layer launchers and should not necessarily appear as normal actions.")
    lines.append("- `tool` scripts are repository maintenance tools.")
    lines.append("- `library` scripts support other scripts.")
    lines.append("- `root_operator` scripts are repo-construction or repair helpers and should not be treated as end-user actions.")
    lines.append("- `unindexed` scripts require review before expansion.")
    lines.append("")
    lines.append("## Next recommended work")
    lines.append("")
    lines.append("1. Review any unindexed scripts.")
    lines.append("2. Review risk-pattern hits and confirm whether each is plan-only, read-only, or intentionally operator-only.")
    lines.append("3. After this audit floor is accepted, add `help-desk-evidence-v1` as the next action layer.")
    lines.append("")

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="")

    print(f"RESULT={result}")
    print(f"ACTION_INDEX_SOURCE={action_source_path}")
    print(f"ACTION_COUNT={len(actions)}")
    print(f"POWERSHELL_SCRIPT_COUNT={len(ps_scripts)}")
    print(f"MISSING_SCRIPT_REF_COUNT={len(missing_script_refs)}")
    print(f"EMPTY_SCRIPT_REF_COUNT={len(empty_script_refs)}")
    print(f"DUPLICATE_ACTION_ID_COUNT={len(duplicate_ids)}")
    print(f"UNINDEXED_SCRIPT_COUNT={len(unindexed)}")
    print(f"RISK_PATTERN_HIT_COUNT={len(risk_hits)}")
    print(f"WROTE={rel(REPORT)}")

    if hard_failures:
        print("HARD_FAILURES=" + ",".join(hard_failures))
        sys.exit(1)

if __name__ == "__main__":
    main()
