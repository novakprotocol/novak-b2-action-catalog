#!/usr/bin/env python3
from __future__ import annotations

import json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PATH = ROOT / "catalog/generated/adapters/ai/action-contract.sample.json"
HEX64 = re.compile(r"^[a-f0-9]{64}$")
REQ = [
  "schema_version","action_number","action_id","title","description","domain","subdomain",
  "category","platform","persona","support_level","authority_required","safety_class",
  "mutation_allowed","approval_required","secret_policy","target_policy","network_scan_allowed",
  "runtime_context","script_path","script_sha256","hash_policy","inputs","outputs",
  "evidence_contract","sanitization_policy","adapter_hints","status","accepted_for_baseline",
  "accepted_for_mutation","created_utc","updated_utc"
]

def fail(msg: str) -> None:
    print(f"FAIL validate_action_contract_required_fields {msg}")
    sys.exit(1)

payload = json.loads(PATH.read_text(encoding="utf-8")) if PATH.exists() else fail("missing sample contract")
actions = payload.get("actions")
if not isinstance(actions, list) or not actions:
    fail("missing actions")
seen = set()
for a in actions:
    missing = [x for x in REQ if x not in a]
    if missing:
        fail(f"missing={missing} action_id={a.get('action_id')}")
    aid = a["action_id"]
    if aid in seen:
        fail(f"duplicate action_id={aid}")
    seen.add(aid)
    checks = [
      (a["schema_version"] == "action-contract.v1", "schema_version"),
      (a["safety_class"] == "evidence_only", "safety_class"),
      (a["mutation_allowed"] is False, "mutation_allowed"),
      (a["approval_required"] is False, "approval_required"),
      (a["secret_policy"] == "no_secrets", "secret_policy"),
      (a["target_policy"] == "no_targets", "target_policy"),
      (a["network_scan_allowed"] is False, "network_scan_allowed"),
      (a["accepted_for_mutation"] is False, "accepted_for_mutation"),
      (a["hash_policy"] == "lf-normalized-sha256", "hash_policy"),
      (HEX64.match(a["script_sha256"]) is not None, "script_sha256"),
      ((ROOT / a["script_path"]).exists(), "script_path"),
    ]
    for ok, name in checks:
        if not ok:
            fail(f"bad {name} action_id={aid}")
print(f"PASS validate_action_contract_required_fields actions={len(actions)}")
