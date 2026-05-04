#!/usr/bin/env python3
"""Generate bounded Adapter Export Layer v1 preview outputs.

Reads catalog/generated/action-index.json and existing action-layer PowerShell
files. Emits preview-only adapter artifacts. No live platform calls. No mutation.
"""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import re
from pathlib import Path
from typing import Any, Dict, Iterable, List

ROOT = Path(__file__).resolve().parents[2]
INDEX_PATH = ROOT / "catalog" / "generated" / "action-index.json"
OUT_DIR = ROOT / "catalog" / "generated" / "adapters"

ACTION_ID_RE = re.compile(r"-ActionId\s+'([^']+)'")
TITLE_RE = re.compile(r"-Title\s+'([^']+)'")
NUMBER_RE = re.compile(r"-Number\s+([0-9]+)")
LAYER_RE = re.compile(r"-LayerId\s+'([^']+)'")
AUDIENCE_RE = re.compile(r"-Audience\s+'([^']+)'")
TIER_RE = re.compile(r"-Tier\s+'([^']+)'")
HEX64 = re.compile(r"^[a-fA-F0-9]{64}$")
FORBIDDEN = (
    "remove-item", "restart-service", "stop-service", "set-acl",
    "new-smbshare", "remove-smbshare", "set-netfirewall", "format-volume",
    "clear-disk", "resize-partition",
)


def fail(message: str) -> None:
    raise SystemExit(f"FAIL {message}")


def walk(node: Any) -> Iterable[Dict[str, Any]]:
    if isinstance(node, dict):
        yield node
        for value in node.values():
            yield from walk(value)
    elif isinstance(node, list):
        for item in node:
            yield from walk(item)


def norm_path(value: str) -> str:
    return value.replace("\\", "/").strip()


def ps1_paths_in(node: Dict[str, Any]) -> List[str]:
    paths: List[str] = []
    for value in node.values():
        if isinstance(value, str):
            candidate = norm_path(value)
            if candidate.startswith("action-layers/") and candidate.lower().endswith(".ps1"):
                if "/scripts/checks/000-Run-" not in candidate:
                    paths.append(candidate)
    return sorted(set(paths))


def lf_sha256(path: Path) -> str:
    data = path.read_bytes().replace(b"\r\n", b"\n").replace(b"\r", b"\n")
    return hashlib.sha256(data).hexdigest()


def first_hash(node: Dict[str, Any]) -> str | None:
    for key, value in node.items():
        if isinstance(value, str) and HEX64.match(value) and ("sha256" in str(key).lower() or "hash" in str(key).lower()):
            return value.lower()
    return None


def pick(regex: re.Pattern[str], text: str) -> str | None:
    match = regex.search(text)
    return match.group(1).strip() if match else None


def parse_script(path: Path) -> Dict[str, Any]:
    text = path.read_text(encoding="utf-8", errors="ignore")
    lowered = text.lower()
    for word in FORBIDDEN:
        if word in lowered:
            fail(f"forbidden mutation-like verb in {path.relative_to(ROOT)}: {word}")
    number = pick(NUMBER_RE, text)
    return {
        "action_number": int(number) if number else None,
        "action_id": pick(ACTION_ID_RE, text),
        "title": pick(TITLE_RE, text),
        "layer_id": pick(LAYER_RE, text),
        "persona": pick(AUDIENCE_RE, text),
        "support_level": pick(TIER_RE, text),
    }


def derive_platform(script_path: str) -> str:
    parts = script_path.split("/")
    return parts[1] if len(parts) > 1 else "unknown"


def derive_domain(script_path: str) -> str:
    parts = script_path.split("/")
    return parts[2] if len(parts) > 2 else "unknown"


def title_from_id(action_id: str) -> str:
    text = re.sub(r"_V[0-9]+$", "", action_id)
    text = text.replace("ENDUSER_", "").replace("STORAGEADMIN_", "")
    return text.replace("_", " ").title()


def build_contract(node: Dict[str, Any], script_path: str) -> Dict[str, Any]:
    abs_path = ROOT / script_path
    if not abs_path.exists():
        fail(f"missing script file: {script_path}")
    meta = parse_script(abs_path)
    action_id = node.get("action_id") or node.get("id") or meta.get("action_id")
    if not isinstance(action_id, str) or not action_id:
        fail(f"missing action_id for {script_path}")
    action_number = node.get("action_number") or node.get("number") or meta.get("action_number")
    if action_number is None:
        fail(f"missing action_number for {action_id}")
    title = node.get("title") or meta.get("title") or title_from_id(action_id)
    return {
        "schema_version": "action-contract.v1",
        "action_number": int(action_number),
        "action_id": action_id,
        "title": title,
        "description": node.get("description") or f"Evidence-only action projection for {title}.",
        "domain": node.get("domain") or derive_domain(script_path),
        "subdomain": node.get("subdomain") or meta.get("layer_id") or derive_domain(script_path),
        "category": node.get("category") or "evidence",
        "platform": node.get("platform") or derive_platform(script_path),
        "persona": node.get("persona") or meta.get("persona") or "operator",
        "support_level": node.get("support_level") or meta.get("support_level") or "unassigned",
        "authority_required": node.get("authority_required") or "read_only_local_or_approved_inventory_context",
        "safety_class": node.get("safety_class") or "evidence_only",
        "mutation_allowed": False,
        "approval_required": False,
        "secret_policy": "no_secrets",
        "target_policy": "no_targets",
        "network_scan_allowed": False,
        "runtime_context": "platform_preview_no_live_execution",
        "script_path": script_path,
        "script_sha256": first_hash(node) or lf_sha256(abs_path),
        "hash_policy": "lf-normalized-sha256",
        "inputs": [],
        "outputs": ["sanitized evidence summary"],
        "evidence_contract": {
            "captures": ["status", "configuration", "count", "risk_category", "guidance"],
            "redaction_required": True,
            "ticket_ready": True
        },
        "sanitization_policy": "sanitize_paths_identities_targets_and_environment_specific_values",
        "adapter_hints": {
            "ai": "explain_select_recommend_only_no_execution_approval",
            "human": "runbook_preview_evidence_only",
            "ansible": "preview_metadata_only",
            "awx": "job_template_preview_no_inventory_no_platform_credential",
            "aws_ssm": "document_preview_echo_only",
            "servicenow": "import_set_preview_metadata_only",
            "cmdb": "candidate_mapping_preview_metadata_only"
        },
        "status": node.get("status") or "accepted",
        "accepted_for_baseline": True,
        "accepted_for_mutation": False,
        "created_utc": str(node.get("created_utc") or ""),
        "updated_utc": dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    }


def load_contracts(index_path: Path = INDEX_PATH) -> List[Dict[str, Any]]:
    if not index_path.exists():
        fail(f"missing action index: {index_path}")
    index = json.loads(index_path.read_text(encoding="utf-8"))
    by_id: Dict[str, Dict[str, Any]] = {}
    for node in walk(index):
        paths = ps1_paths_in(node)
        if len(paths) != 1:
            continue
        contract = build_contract(node, paths[0])
        by_id[contract["action_id"]] = contract
    contracts = sorted(by_id.values(), key=lambda c: (int(c["action_number"]), c["action_id"]))
    if not contracts:
        fail("no action contracts generated")
    return contracts


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def q(value: Any) -> str:
    return "'" + str(value).replace("'", "''") + "'"


def write_ansible(path: Path, contracts: List[Dict[str, Any]]) -> None:
    lines = [
        "---",
        "- name: NOVAK Action Catalog Adapter Export Layer v1 preview",
        "  hosts: all",
        "  gather_facts: false",
        "  vars:",
        "    adapter_boundary: evidence_only_preview",
        "    mutation_allowed: false",
        "    live_platform_calls_allowed: false",
        "  tasks:",
    ]
    for c in contracts:
        lines += [
            f"    - name: Preview {c['action_number']} {c['action_id']}",
            "      ansible.builtin.debug:",
            "        msg:",
            f"          action_id: {q(c['action_id'])}",
            f"          action_number: {c['action_number']}",
            f"          script_path: {q(c['script_path'])}",
            f"          script_sha256: {q(c['script_sha256'])}",
            "          mutation_allowed: false",
        ]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_runbook(path: Path, contracts: List[Dict[str, Any]]) -> None:
    lines = [
        "# Adapter Export Layer v1 Human Runbook Preview", "",
        "Boundary: evidence-only, no mutation, no live platform integration, no platform credential reference, no raw target list.", "",
        "| Action | Title | Script | Hash | Boundary |",
        "| --- | --- | --- | --- | --- |",
    ]
    for c in contracts:
        lines.append(f"| {c['action_number']} `{c['action_id']}` | {c['title']} | `{c['script_path']}` | `{c['script_sha256']}` | evidence-only |")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_ssm(path: Path, contracts: List[Dict[str, Any]]) -> None:
    lines = [
        "schemaVersion: '2.2'",
        "description: 'NOVAK Action Catalog Adapter Export Layer v1 preview. Echo-only metadata. No live evidence collection.'",
        "mainSteps:",
        "  - action: aws:runPowerShellScript",
        "    name: PreviewActionCatalogEvidenceContracts",
        "    inputs:",
        "      runCommand:",
    ]
    for c in contracts:
        lines += [
            f"        - {q('Write-Output \"ACTION_ID=' + c['action_id'] + '\"')}",
            f"        - {q('Write-Output \"SCRIPT_PATH=' + c['script_path'] + '\"')}",
            f"        - {q('Write-Output \"SCRIPT_SHA256=' + c['script_sha256'] + '\"')}",
            f"        - {q('Write-Output \"MUTATION_ALLOWED=false\"')}",
        ]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_exports(contracts: List[Dict[str, Any]], out_dir: Path) -> None:
    now = dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    manifest = {
        "schema_version": "adapter-manifest.v1",
        "generated_utc": now,
        "source_index": "catalog/generated/action-index.json",
        "source_action_count": len(load_contracts()),
        "sample_count": len(contracts),
        "bounded_preview": True,
        "boundary": {
            "safety_class": "evidence_only",
            "mutation_allowed": False,
            "live_platform_calls_allowed": False,
            "secrets_allowed": False,
            "raw_target_lists_allowed": False,
            "network_scan_allowed": False
        },
        "adapters": [
            "ai/action-contract.sample.json",
            "human/runbook.sample.md",
            "ansible/playbook.sample.yml",
            "awx/job-template.sample.json",
            "aws/ssm-document.sample.yaml",
            "servicenow/import-set.sample.json",
            "cmdb/ci-evidence-mapping.sample.json"
        ],
        "sample_actions": [{"action_id": c["action_id"], "action_number": c["action_number"], "script_path": c["script_path"], "script_sha256": c["script_sha256"]} for c in contracts]
    }
    write_json(out_dir / "adapter-manifest.json", manifest)
    write_json(out_dir / "ai" / "action-contract.sample.json", {"schema_version": "action-contract-sample.v1", "actions": contracts})
    write_runbook(out_dir / "human" / "runbook.sample.md", contracts)
    write_ansible(out_dir / "ansible" / "playbook.sample.yml", contracts)
    write_json(out_dir / "awx" / "job-template.sample.json", {"schema_version": "awx-job-template-preview.v1", "name": "NOVAK Action Catalog Evidence Preview", "job_type": "check", "inventory_required": False, "platform_credential_reference_required": False, "mutation_allowed": False, "actions": contracts})
    write_ssm(out_dir / "aws" / "ssm-document.sample.yaml", contracts)
    write_json(out_dir / "servicenow" / "import-set.sample.json", {"schema_version": "servicenow-import-set-preview.v1", "table": "u_novak_action_catalog_evidence_preview", "auto_assign": False, "auto_close": False, "auto_prioritize": False, "change_approval_created": False, "records": contracts})
    write_json(out_dir / "cmdb" / "ci-evidence-mapping.sample.json", {"schema_version": "cmdb-ci-evidence-mapping-preview.v1", "authoritative_ci_assertion": False, "ownership_assertion": False, "mapping_rule": "candidate evidence metadata only", "records": contracts})


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--sample-count", type=int, default=10)
    parser.add_argument("--index", type=Path, default=INDEX_PATH)
    parser.add_argument("--out-dir", type=Path, default=OUT_DIR)
    args = parser.parse_args()
    if args.sample_count < 1 or args.sample_count > 25:
        fail("sample-count must be between 1 and 25")
    contracts = load_contracts(args.index)
    sample = contracts[:args.sample_count]
    write_exports(sample, args.out_dir)
    print(f"PASS generate_adapter_exports source_actions={len(contracts)} sample_count={len(sample)} out_dir={args.out_dir.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
