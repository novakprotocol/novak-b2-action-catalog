#!/usr/bin/env python3
"""
validate_adapter_contract_hardening_v2.py

Hardening checks for the NOVAK Action Catalog Adapter Export Layer v1 scaleout floor.

This validator is intentionally read-only. It does not regenerate adapters,
touch platform APIs, execute scripts, or infer live inventory.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any, Iterable


REPO = Path.cwd()

REQUIRED_FILES = [
    "catalog/generated/action-index.json",
    "catalog/generated/adapters-v1-scaleout/adapter-manifest.json",
    "catalog/generated/adapters-v1-scaleout/ai/action-contracts.jsonl",
    "catalog/generated/adapters-v1-scaleout/human/runbook-index.md",
    "catalog/generated/adapters-v1-scaleout/ansible/action-catalog-vars.yml",
    "catalog/generated/adapters-v1-scaleout/awx/job-template-candidates.json",
    "catalog/generated/adapters-v1-scaleout/aws/ssm-document-candidates.yaml",
    "catalog/generated/adapters-v1-scaleout/kubernetes/job-candidates.yaml",
    "catalog/generated/adapters-v1-scaleout/openshift/job-candidates.yaml",
    "catalog/generated/adapters-v1-scaleout/servicenow/import-set.json",
    "catalog/generated/adapters-v1-scaleout/cmdb/ci-evidence-mapping.json",
    "catalog/generated/adapters-v1-scaleout/gitops/kustomization-preview.yaml",
    "catalog/releases/adapter-export-layer-v1-scaleout-accepted-baseline.json",
]

EXPECTED_ADAPTERS = {
    "ai",
    "human",
    "ansible",
    "awx",
    "aws",
    "kubernetes",
    "openshift",
    "servicenow",
    "cmdb",
    "gitops",
}

SECRET_OR_RAW_TARGET_PATTERNS = [
    re.compile(r"AKIA[0-9A-Z]{16}"),
    re.compile(r"(?i)aws_secret_access_key\s*[:=]\s*['\"][^'\"]+"),
    re.compile(r"(?i)password\s*[:=]\s*['\"][^'\"]+"),
    re.compile(r"(?i)passwd\s*[:=]\s*['\"][^'\"]+"),
    re.compile(r"(?i)token\s*[:=]\s*['\"][A-Za-z0-9_\-\.]{16,}"),
    re.compile(r"(?i)client_secret\s*[:=]\s*['\"][^'\"]+"),
    re.compile(r"(?i)private_key\s*[:=]"),
    re.compile(r"(?i)BEGIN\s+(RSA|OPENSSH|EC|DSA)?\s*PRIVATE KEY"),
    re.compile(r"(?i)\b\d{1,3}(?:\.\d{1,3}){3}\b"),
    re.compile(r"(?i)\\\\[a-z0-9_.-]+\\[^\s\"']+"),
]

MUTATION_TRUE_PATTERNS = [
    re.compile(r"(?i)mutation_allowed\s*[:=]\s*true"),
    re.compile(r"(?i)mutationAllowed\s*[:=]\s*true"),
    re.compile(r'"mutation_allowed"\s*:\s*true'),
    re.compile(r'"mutationAllowed"\s*:\s*true'),
]


def die(message: str) -> None:
    print(f"FAIL validate_adapter_contract_hardening_v2 {message}", file=sys.stderr)
    raise SystemExit(1)


def read_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8-sig"))
    except Exception as exc:
        die(f"invalid_json path={path} error={exc}")


def walk_lists(obj: Any) -> Iterable[list[Any]]:
    if isinstance(obj, list):
        yield obj
        for item in obj:
            yield from walk_lists(item)
    elif isinstance(obj, dict):
        for value in obj.values():
            yield from walk_lists(value)


def candidate_action_list(obj: Any) -> list[dict[str, Any]]:
    best: list[dict[str, Any]] = []
    for value in walk_lists(obj):
        if not value or not all(isinstance(item, dict) for item in value[: min(len(value), 5)]):
            continue
        score = 0
        sample = value[: min(len(value), 25)]
        for item in sample:
            keys = set(item.keys())
            if keys & {"action_id", "actionId", "id"}:
                score += 1
            if keys & {"action_number", "actionNumber", "number"}:
                score += 1
            if keys & {"script_path", "scriptPath", "path"}:
                score += 1
        if score > 0 and len(value) > len(best):
            best = [item for item in value if isinstance(item, dict)]
    return best


def get_first(obj: dict[str, Any], names: list[str]) -> Any:
    for name in names:
        if name in obj:
            return obj[name]
    return None


def contract_key(obj: dict[str, Any]) -> tuple[str, str]:
    action_id = get_first(obj, ["action_id", "actionId", "id"])
    action_number = get_first(obj, ["action_number", "actionNumber", "number"])
    script_path = get_first(obj, ["script_path", "scriptPath", "path"])
    if action_id is None and script_path is not None:
        action_id = str(script_path)
    if action_number is None and script_path is not None:
        match = re.search(r"[/\\](\d+)-[^/\\]+\.ps1$", str(script_path))
        if match:
            action_number = match.group(1)
    return (str(action_id or "").strip(), str(action_number or "").strip())


def read_jsonl(path: Path) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for line_no, line in enumerate(path.read_text(encoding="utf-8-sig").splitlines(), start=1):
        if not line.strip():
            continue
        try:
            obj = json.loads(line)
        except Exception as exc:
            die(f"invalid_jsonl path={path} line={line_no} error={exc}")
        if not isinstance(obj, dict):
            die(f"jsonl_row_not_object path={path} line={line_no}")
        rows.append(obj)
    return rows


def scan_text_boundaries(paths: list[Path]) -> None:
    for path in paths:
        text = path.read_text(encoding="utf-8-sig", errors="replace")
        for pattern in SECRET_OR_RAW_TARGET_PATTERNS:
            match = pattern.search(text)
            if match:
                die(f"possible_secret_or_raw_target path={path} pattern={pattern.pattern}")
        for pattern in MUTATION_TRUE_PATTERNS:
            match = pattern.search(text)
            if match:
                die(f"mutation_leak path={path} pattern={pattern.pattern}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--expected-actions", type=int, default=5000)
    parser.add_argument("--expected-adapters", type=int, default=10)
    args = parser.parse_args()

    missing = [path for path in REQUIRED_FILES if not (REPO / path).exists()]
    if missing:
        die("missing_required_files=" + ",".join(missing))

    action_index = read_json(REPO / "catalog/generated/action-index.json")
    source_actions = candidate_action_list(action_index)
    if len(source_actions) != args.expected_actions:
        die(f"source_action_count expected={args.expected_actions} actual={len(source_actions)}")

    contracts = read_jsonl(REPO / "catalog/generated/adapters-v1-scaleout/ai/action-contracts.jsonl")
    if len(contracts) != args.expected_actions:
        die(f"contract_count expected={args.expected_actions} actual={len(contracts)}")

    keys: set[tuple[str, str]] = set()
    for idx, contract in enumerate(contracts, start=1):
        action_id, action_number = contract_key(contract)
        if not action_id:
            die(f"contract_missing_action_id row={idx}")
        if not action_number:
            die(f"contract_missing_action_number row={idx} action_id={action_id}")
        key = (action_id, action_number)
        if key in keys:
            die(f"duplicate_contract_key row={idx} key={key}")
        keys.add(key)

        for forbidden in ["credential", "password", "secret", "raw_target", "live_api_call"]:
            value = contract.get(forbidden)
            if value is True:
                die(f"forbidden_boolean_true row={idx} field={forbidden}")

        mutation_allowed = contract.get("mutation_allowed", contract.get("mutationAllowed", False))
        if mutation_allowed is True:
            die(f"mutation_allowed_true row={idx} action_id={action_id}")

    manifest = read_json(REPO / "catalog/generated/adapters-v1-scaleout/adapter-manifest.json")
    manifest_text = json.dumps(manifest, sort_keys=True)
    discovered = {adapter for adapter in EXPECTED_ADAPTERS if adapter in manifest_text.lower()}
    if len(discovered) < args.expected_adapters:
        die(f"adapter_manifest_adapter_coverage expected>={args.expected_adapters} actual={len(discovered)} discovered={sorted(discovered)}")

    scan_paths = [REPO / path for path in REQUIRED_FILES if path.startswith("catalog/generated/adapters-v1-scaleout/")]
    scan_text_boundaries(scan_paths)

    print(
        "PASS validate_adapter_contract_hardening_v2 "
        f"source_actions={len(source_actions)} contracts={len(contracts)} "
        f"adapters={len(discovered)}"
    )


if __name__ == "__main__":
    main()
