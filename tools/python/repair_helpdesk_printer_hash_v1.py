#!/usr/bin/env python3
from pathlib import Path
import csv
import hashlib
import json
import sys

ROOT = Path.cwd()

ACTION_ID = "ENDUSER_HELPDESK_PRINTER_SUMMARY_V1"
SCRIPT_PATH = "action-layers/windows/end-user/help-desk-evidence-v1/scripts/checks/549-helpdesk-printer-summary.ps1"
ACTION_INDEX = ROOT / "catalog" / "generated" / "action-index.json"
MANIFEST_JSON = ROOT / "action-layers" / "windows" / "end-user" / "help-desk-evidence-v1" / "manifest.help-desk-evidence-v1.json"
MANIFEST_CSV = ROOT / "action-layers" / "windows" / "end-user" / "help-desk-evidence-v1" / "manifest.help-desk-evidence-v1.csv"

HASH_KEYS = ["script_sha256", "sha256", "script_hash", "hash"]

def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def update_record(record: dict, digest: str) -> bool:
    matched = record.get("action_id") == ACTION_ID or record.get("script_path") == SCRIPT_PATH
    if not matched:
        return False

    record["script_path"] = SCRIPT_PATH
    for key in HASH_KEYS:
        if key in record:
            record[key] = digest

    return True

digest = sha256_file(ROOT / SCRIPT_PATH)
updated = 0

index = json.loads(ACTION_INDEX.read_text(encoding="utf-8"))
actions = index.get("actions")
if not isinstance(actions, list):
    print("FAIL action-index.json missing actions list")
    sys.exit(1)

for record in actions:
    if isinstance(record, dict) and update_record(record, digest):
        updated += 1

ACTION_INDEX.write_text(json.dumps(index, indent=2) + "\n", encoding="utf-8", newline="")

manifest = json.loads(MANIFEST_JSON.read_text(encoding="utf-8"))
if not isinstance(manifest, list):
    print("FAIL manifest json is not a list")
    sys.exit(1)

manifest_updates = 0
for record in manifest:
    if isinstance(record, dict) and update_record(record, digest):
        manifest_updates += 1

MANIFEST_JSON.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8", newline="")

rows = []
with MANIFEST_CSV.open("r", encoding="utf-8", newline="") as handle:
    reader = csv.DictReader(handle)
    fieldnames = reader.fieldnames or []
    for row in reader:
        if row.get("action_id") == ACTION_ID or row.get("script_path") == SCRIPT_PATH:
            row["script_path"] = SCRIPT_PATH
            for key in HASH_KEYS:
                if key in row:
                    row[key] = digest
        rows.append(row)

with MANIFEST_CSV.open("w", encoding="utf-8", newline="") as handle:
    writer = csv.DictWriter(handle, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)

print(f"UPDATED_ACTION_INDEX_RECORDS={updated}")
print(f"UPDATED_MANIFEST_JSON_RECORDS={manifest_updates}")
print(f"UPDATED_HASH={digest}")

if updated != 1 or manifest_updates != 1:
    print("FAIL expected exactly one action-index and one manifest-json update")
    sys.exit(1)
