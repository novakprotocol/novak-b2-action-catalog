#!/usr/bin/env python3
from __future__ import annotations
import argparse, datetime as dt, hashlib, json, re
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
INDEX = ROOT / "catalog" / "generated" / "action-index.json"
OUT = ROOT / "catalog" / "generated" / "adapters"

ACTION_ID = re.compile(r"-ActionId\s+['\"]([^'\"]+)['\"]", re.IGNORECASE)
TITLE = re.compile(r"-Title\s+['\"]([^'\"]+)['\"]", re.IGNORECASE)
NUMBER = re.compile(r"-Number\s+([0-9]+)", re.IGNORECASE)
LAYER = re.compile(r"-LayerId\s+['\"]([^'\"]+)['\"]", re.IGNORECASE)
AUDIENCE = re.compile(r"-Audience\s+['\"]([^'\"]+)['\"]", re.IGNORECASE)
TIER = re.compile(r"-Tier\s+['\"]([^'\"]+)['\"]", re.IGNORECASE)
HEX64 = re.compile(r"^[a-fA-F0-9]{64}$")
FORBIDDEN = ("remove-item","restart-service","stop-service","set-acl","new-smbshare","remove-smbshare","set-netfirewall","format-volume","clear-disk","resize-partition")

def fail(message: str) -> None:
    raise SystemExit(f"FAIL {message}")

def walk(node: Any):
    if isinstance(node, dict):
        yield node
        for value in node.values():
            yield from walk(value)
    elif isinstance(node, list):
        for item in node:
            yield from walk(item)

def norm_path(value: str) -> str:
    return value.replace("\\", "/").strip()

def script_paths(node: dict[str, Any]) -> list[str]:
    found = []
    for value in node.values():
        if isinstance(value, str):
            path = norm_path(value)
            if path.startswith("action-layers/") and path.lower().endswith(".ps1") and "/scripts/checks/000-Run-" not in path:
                found.append(path)
    return sorted(set(found))

def lf_sha256(path: Path) -> str:
    data = path.read_bytes().replace(b"\r\n", b"\n").replace(b"\r", b"\n")
    return hashlib.sha256(data).hexdigest()

def first_hash(node: dict[str, Any]) -> str | None:
    for key, value in node.items():
        if isinstance(value, str) and HEX64.match(value) and ("sha256" in str(key).lower() or "hash" in str(key).lower()):
            return value.lower()
    return None

def pick(regex: re.Pattern[str], text: str) -> str | None:
    match = regex.search(text)
    return match.group(1).strip() if match else None

def parse_script(path: Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8", errors="ignore")
    lower = text.lower()
    for word in FORBIDDEN:
        if word in lower:
            fail(f"forbidden mutation-like token in {path.relative_to(ROOT)}: {word}")
    number = pick(NUMBER, text)
    return {
        "action_number": int(number) if number else None,
        "action_id": pick(ACTION_ID, text),
        "title": pick(TITLE, text),
        "layer_id": pick(LAYER, text),
        "persona": pick(AUDIENCE, text),
        "support_level": pick(TIER, text),
    }

def rel_parts(rel: str) -> list[str]:
    return [x for x in rel.replace("\\", "/").split("/") if x]

def number_from_filename(rel: str) -> int | None:
    match = re.match(r"^([0-9]+)[-_]", Path(rel).name)
    return int(match.group(1)) if match else None

def fallback_action_id(rel: str, number: int | None) -> str:
    parts = rel_parts(rel)
    layer = parts[3] if len(parts) > 3 else "action"
    stem = re.sub(r"^[0-9]+[-_]", "", Path(rel).stem)
    token = re.sub(r"[^A-Za-z0-9]+", "_", f"{layer}-{stem}").strip("_").upper() or "ACTION"
    if number is not None:
        token = f"{token}_{number:04d}"
    return token if token.endswith("_V1") else f"{token}_V1"

def fallback_title(rel: str) -> str:
    stem = re.sub(r"^[0-9]+[-_]", "", Path(rel).stem)
    return re.sub(r"[-_]+", " ", stem).strip().title()

def contract_from(node: dict[str, Any], rel: str) -> dict[str, Any]:
    path = ROOT / rel
    if not path.exists():
        fail(f"missing script: {rel}")
    meta = parse_script(path)
    number = node.get("action_number") or node.get("number") or meta.get("action_number") or number_from_filename(rel)
    if number is None:
        fail(f"missing action number for {rel}")
    action_id = node.get("action_id") or node.get("id") or meta.get("action_id") or fallback_action_id(rel, int(number))
    parts = rel_parts(rel)
    layer_id = meta.get("layer_id") or (parts[3] if len(parts) > 3 else "unknown")
    title = node.get("title") or meta.get("title") or fallback_title(rel)
    now = dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    return {
        "schema_version": "action-contract.v1",
        "action_number": int(number),
        "action_id": str(action_id),
        "title": str(title),
        "description": str(node.get("description") or f"Evidence-only action projection for {title}."),
        "domain": str(node.get("domain") or (parts[2] if len(parts) > 2 else "unknown")),
        "subdomain": str(node.get("subdomain") or layer_id),
        "category": str(node.get("category") or "evidence"),
        "platform": str(node.get("platform") or (parts[1] if len(parts) > 1 else "unknown")),
        "persona": str(node.get("persona") or meta.get("persona") or "operator"),
        "support_level": str(node.get("support_level") or meta.get("support_level") or "unassigned"),
        "authority_required": "read_only_local_or_approved_inventory_context",
        "safety_class": "evidence_only",
        "mutation_allowed": False,
        "approval_required": False,
        "secret_policy": "no_secrets",
        "target_policy": "no_targets",
        "network_scan_allowed": False,
        "runtime_context": "platform_preview_no_live_execution",
        "script_path": rel,
        "script_sha256": first_hash(node) or lf_sha256(path),
        "hash_policy": "lf-normalized-sha256",
        "inputs": [],
        "outputs": ["sanitized evidence summary"],
        "evidence_contract": {"redaction_required": True, "ticket_ready": True},
        "sanitization_policy": "sanitize_paths_identities_targets_and_environment_specific_values",
        "adapter_hints": {
            "ai": "explain_select_recommend_only_no_execution_approval",
            "human": "runbook_preview_evidence_only",
            "ansible": "preview_metadata_only",
            "awx": "job_template_preview_no_credential",
            "aws_ssm": "document_preview_echo_only",
            "servicenow": "import_set_preview_metadata_only",
            "cmdb": "candidate_mapping_preview_metadata_only",
        },
        "status": str(node.get("status") or "accepted"),
        "accepted_for_baseline": True,
        "accepted_for_mutation": False,
        "created_utc": str(node.get("created_utc") or ""),
        "updated_utc": now,
    }

def load_contracts(index_path: Path) -> list[dict[str, Any]]:
    data = json.loads(index_path.read_text(encoding="utf-8"))
    by_key = {}
    for node in walk(data):
        paths = script_paths(node)
        if len(paths) == 1:
            item = contract_from(node, paths[0])
            by_key[f"{item['script_path']}::{item['action_id']}"] = item
    out = sorted(by_key.values(), key=lambda x: (int(x["action_number"]), str(x["action_id"]), str(x["script_path"])))
    if not out:
        fail("no contracts generated")
    return out

def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")

def sq(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"

def emit(sample: list[dict[str, Any]], source_count: int, out_dir: Path) -> None:
    now = dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    adapters = ["ai/action-contract.sample.json","human/runbook.sample.md","ansible/playbook.sample.yml","awx/job-template.sample.json","aws/ssm-document.sample.yaml","servicenow/import-set.sample.json","cmdb/ci-evidence-mapping.sample.json"]
    manifest = {
        "schema_version": "adapter-manifest.v1",
        "generated_utc": now,
        "source_index": "catalog/generated/action-index.json",
        "source_action_count": source_count,
        "sample_count": len(sample),
        "bounded_preview": True,
        "boundary": {"safety_class":"evidence_only","mutation_allowed":False,"live_platform_calls_allowed":False,"secrets_allowed":False,"raw_target_lists_allowed":False,"network_scan_allowed":False},
        "adapters": adapters,
        "sample_actions": [{"action_id": c["action_id"], "action_number": c["action_number"], "script_path": c["script_path"], "script_sha256": c["script_sha256"]} for c in sample],
    }
    write_json(out_dir / "adapter-manifest.json", manifest)
    write_json(out_dir / "ai" / "action-contract.sample.json", {"schema_version": "action-contract-sample.v1", "actions": sample})
    runbook = "# Adapter Export Layer v1 Human Runbook Preview\n\nBoundary: evidence-only. No mutation. No credentials. No raw targets.\n\n"
    runbook += "\n".join(f"- {c['action_number']} {c['action_id']} -> {c['script_path']} ({c['script_sha256']})" for c in sample) + "\n"
    write_text(out_dir / "human" / "runbook.sample.md", runbook)
    playbook = "---\n- name: NOVAK Action Catalog adapter preview\n  hosts: all\n  gather_facts: false\n  tasks:\n"
    playbook += "\n".join(
        f"    - name: Preview {c['action_id']}\n      ansible.builtin.debug:\n        msg:\n          action_id: {sq(c['action_id'])}\n          script_path: {sq(c['script_path'])}\n          script_sha256: {sq(c['script_sha256'])}\n          mutation_allowed: false"
        for c in sample
    ) + "\n"
    write_text(out_dir / "ansible" / "playbook.sample.yml", playbook)
    write_json(out_dir / "awx" / "job-template.sample.json", {"schema_version":"awx-job-template-preview.v1","inventory_required":False,"platform_credential_reference_required":False,"mutation_allowed":False,"actions":sample})
    ssm = "schemaVersion: '2.2'\ndescription: 'NOVAK adapter preview. Echo-only metadata.'\nmainSteps:\n  - action: aws:runPowerShellScript\n    name: PreviewActionCatalogEvidenceContracts\n    inputs:\n      runCommand:\n"
    ssm += "\n".join(f"        - {sq('Write-Output ACTION_ID=' + c['action_id'])}" for c in sample) + "\n"
    write_text(out_dir / "aws" / "ssm-document.sample.yaml", ssm)
    write_json(out_dir / "servicenow" / "import-set.sample.json", {"schema_version":"servicenow-import-set-preview.v1","auto_assign":False,"auto_close":False,"auto_prioritize":False,"change_approval_created":False,"records":sample})
    write_json(out_dir / "cmdb" / "ci-evidence-mapping.sample.json", {"schema_version":"cmdb-ci-evidence-mapping-preview.v1","authoritative_ci_assertion":False,"ownership_assertion":False,"records":sample})

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--sample-count", type=int, default=10)
    parser.add_argument("--index", type=Path, default=INDEX)
    parser.add_argument("--out-dir", type=Path, default=OUT)
    args = parser.parse_args()
    if args.sample_count < 1 or args.sample_count > 25:
        fail("sample-count must be between 1 and 25")
    contracts = load_contracts(args.index)
    emit(contracts[:args.sample_count], len(contracts), args.out_dir)
    print(f"PASS generate_adapter_exports source_actions={len(contracts)} sample_count={args.sample_count}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

