#!/usr/bin/env python3
"""
Validate Adapter Export Layer v1 scaleout outputs.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any, Dict, Iterable, List

ROOT = Path.cwd()
OUT_ROOT = ROOT / "catalog" / "generated" / "adapters-v1-scaleout"
MANIFEST = OUT_ROOT / "adapter-manifest.json"
AI_JSONL = OUT_ROOT / "ai" / "action-contracts.jsonl"

REQUIRED = [
    "schema_version",
    "action_number",
    "action_id",
    "title",
    "description",
    "domain",
    "subdomain",
    "category",
    "platform",
    "persona",
    "support_level",
    "authority_required",
    "safety_class",
    "mutation_allowed",
    "approval_required",
    "secret_policy",
    "target_policy",
    "network_scan_allowed",
    "runtime_context",
    "script_path",
    "script_sha256",
    "hash_policy",
    "inputs",
    "outputs",
    "evidence_contract",
    "sanitization_policy",
    "adapter_hints",
    "status",
    "accepted_for_baseline",
    "accepted_for_mutation",
    "created_utc",
    "updated_utc",
]

FORBIDDEN_REGEXES = [
    re.compile(r"(?i)password\s*[:=]\s*[^,\s]+"),
    re.compile(r"(?i)secret\s*[:=]\s*[^,\s]+"),
    re.compile(r"(?i)token\s*[:=]\s*[^,\s]+"),
    re.compile(r"(?i)access_key\s*[:=]\s*[^,\s]+"),
    re.compile(r"(?i)private_key"),
    re.compile(r"\b\d{1,3}(?:\.\d{1,3}){3}\b"),
]


def fail(msg: str) -> int:
    print(f"FAIL validate_adapter_exports_v1_scaleout {msg}")
    return 1


def read_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def read_jsonl(path: Path) -> List[Dict[str, Any]]:
    rows: List[Dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as f:
        for line_no, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                item = json.loads(line)
            except Exception as exc:
                raise SystemExit(f"invalid JSONL at {path}:{line_no}: {exc}") from exc
            rows.append(item)
    return rows


def assert_no_forbidden_text(path: Path) -> None:
    text = path.read_text(encoding="utf-8", errors="replace")
    for rx in FORBIDDEN_REGEXES:
        m = rx.search(text)
        if m:
            raise SystemExit(f"forbidden sensitive/target-like text in {path}: {m.group(0)[:80]}")


def main() -> int:
    if not MANIFEST.exists():
        return fail(f"missing {MANIFEST}")

    manifest = read_json(MANIFEST)

    if manifest.get("mutation_allowed") is not False:
        return fail("manifest mutation_allowed must be false")
    if manifest.get("approval_authority_granted") is not False:
        return fail("manifest approval_authority_granted must be false")
    if manifest.get("secret_policy") != "no_secrets":
        return fail("manifest secret_policy must be no_secrets")
    if manifest.get("target_policy") != "no_raw_targets":
        return fail("manifest target_policy must be no_raw_targets")
    if manifest.get("live_platform_api_calls") is not False:
        return fail("manifest live_platform_api_calls must be false")

    adapters = manifest.get("adapters")
    if not isinstance(adapters, list) or len(adapters) < 10:
        return fail("expected at least 10 adapters in manifest")

    exported_actions = int(manifest.get("exported_actions", 0))
    if exported_actions <= 0:
        return fail("exported_actions must be greater than zero")

    for adapter in adapters:
        rel = adapter.get("path")
        if not rel:
            return fail("adapter missing path")
        path = ROOT / rel
        if not path.exists():
            return fail(f"missing adapter output {rel}")
        if int(adapter.get("exported_actions", -1)) != exported_actions:
            return fail(f"adapter {adapter.get('name')} exported_actions mismatch")
        assert_no_forbidden_text(path)

    if not AI_JSONL.exists():
        return fail(f"missing {AI_JSONL}")

    contracts = read_jsonl(AI_JSONL)
    if len(contracts) != exported_actions:
        return fail(f"AI JSONL count {len(contracts)} != manifest exported_actions {exported_actions}")

    seen = set()
    for idx, contract in enumerate(contracts, start=1):
        missing = [k for k in REQUIRED if k not in contract]
        if missing:
            return fail(f"contract {idx} missing fields {missing}")

        action_id = str(contract["action_id"])
        if action_id in seen:
            return fail(f"duplicate action_id {action_id}")
        seen.add(action_id)

        if contract["safety_class"] != "evidence_only":
            return fail(f"{action_id} safety_class must be evidence_only")
        if contract["mutation_allowed"] is not False:
            return fail(f"{action_id} mutation_allowed must be false")
        if contract["accepted_for_mutation"] is not False:
            return fail(f"{action_id} accepted_for_mutation must be false")
        if contract["secret_policy"] != "no_secrets":
            return fail(f"{action_id} secret_policy must be no_secrets")
        if contract["target_policy"] != "no_raw_targets":
            return fail(f"{action_id} target_policy must be no_raw_targets")
        if contract["network_scan_allowed"] is not False:
            return fail(f"{action_id} network_scan_allowed must be false")

        sha = str(contract["script_sha256"])
        if not re.fullmatch(r"[0-9a-f]{64}", sha):
            return fail(f"{action_id} invalid script_sha256")

    print(f"PASS validate_adapter_exports_v1_scaleout adapters={len(adapters)} exported_actions={exported_actions}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())