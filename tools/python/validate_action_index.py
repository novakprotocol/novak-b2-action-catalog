#!/usr/bin/env python3
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
INDEX_PATH = ROOT / "catalog" / "generated" / "action-index.json"
HEX64 = re.compile(r"^[a-fA-F0-9]{64}$")

def fail(message: str) -> None:
    print(f"FAIL {message}")
    sys.exit(1)

def norm_path(value: str) -> str:
    return value.replace("\\", "/").strip()

def canonical_sha256(path: Path) -> str:
    data = path.read_bytes()
    data = data.replace(b"\r\n", b"\n").replace(b"\r", b"\n")
    return hashlib.sha256(data).hexdigest()

def walk(node):
    if isinstance(node, dict):
        yield node
        for value in node.values():
            yield from walk(value)
    elif isinstance(node, list):
        for item in node:
            yield from walk(item)

def ps1_paths_in(node: dict):
    paths = []
    for value in node.values():
        if isinstance(value, str):
            candidate = norm_path(value)
            if candidate.startswith("action-layers/") and candidate.lower().endswith(".ps1"):
                paths.append(candidate)
    return paths

if not INDEX_PATH.exists():
    fail(f"missing action index: {INDEX_PATH}")

try:
    index = json.loads(INDEX_PATH.read_text(encoding="utf-8"))
except Exception as exc:
    fail(f"action index JSON parse failed: {exc}")

declared_count = index.get("action_count")
if declared_count is None:
    declared_count = index.get("catalog_action_count")

action_ids = []
mismatches = []
missing_files = []
checked_hashes = 0

for node in walk(index):
    if not isinstance(node, dict):
        continue

    action_id = node.get("action_id") or node.get("id")
    if isinstance(action_id, str) and action_id:
        action_ids.append(action_id)

    paths = ps1_paths_in(node)
    if len(paths) != 1:
        continue

    rel = paths[0]
    script_path = ROOT / rel

    if not script_path.exists():
        missing_files.append(rel)
        continue

    actual = canonical_sha256(script_path)

    for key, value in node.items():
        key_text = str(key).lower()
        if ("sha256" in key_text or "hash" in key_text) and isinstance(value, str) and HEX64.match(value):
            checked_hashes += 1
            expected = value.lower()
            if expected != actual:
                mismatches.append((rel, expected, actual))

if missing_files:
    fail(f"missing script files: {missing_files[:10]}")

if mismatches:
    fail(f"hash mismatch: {mismatches[:10]}")

if checked_hashes == 0:
    fail("no script hashes checked")

if declared_count is not None:
    try:
        declared_int = int(declared_count)
    except Exception:
        fail(f"action_count is not numeric: {declared_count}")

    if declared_int <= 0:
        fail(f"action_count is invalid: {declared_int}")

    if action_ids:
        unique_ids = sorted(set(action_ids))
        if len(unique_ids) != len(action_ids):
            fail("duplicate action_id values detected")

    print(f"PASS validate_action_index actions={declared_int}")
else:
    if not action_ids:
        fail("no action IDs found and no action_count declared")
    print(f"PASS validate_action_index actions={len(set(action_ids))}")
