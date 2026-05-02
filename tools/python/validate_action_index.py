#!/usr/bin/env python3
import json, pathlib, re, sys, hashlib

ROOT = pathlib.Path(__file__).resolve().parents[2]
idx_path = ROOT / "catalog/generated/action-index.json"

def fail(msg):
    print(f"FAIL {msg}", file=sys.stderr)
    sys.exit(1)

idx = json.loads(idx_path.read_text(encoding="utf-8"))
actions = idx.get("actions", [])
if idx.get("action_count") != len(actions):
    fail("action_count does not match actions length")

ids = set()
missing = []
hash_bad = []
for rec in actions:
    aid = rec.get("action_id")
    if not aid:
        fail("action missing action_id")
    if aid in ids:
        fail(f"duplicate action_id {aid}")
    ids.add(aid)

    sp = ROOT / rec.get("script_path", "")
    if not sp.exists():
        missing.append(str(sp.relative_to(ROOT)))
        continue

    expected = rec.get("script_sha256")
    if expected:
        actual = hashlib.sha256(sp.read_bytes()).hexdigest()
        if actual != expected:
            hash_bad.append((str(sp.relative_to(ROOT)), expected, actual))

if missing:
    fail("missing script paths: " + ", ".join(missing[:20]))
if hash_bad:
    fail("hash mismatch: " + repr(hash_bad[:3]))

print(f"PASS validate_action_index actions={len(actions)}")
