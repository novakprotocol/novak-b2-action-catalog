#!/usr/bin/env python3
"""
Generate Adapter Export Layer v1 scaleout outputs.

Design:
- Source of truth remains catalog/generated/action-index.json.
- Output is consolidated platform-native preview artifacts, not 5000 separate files.
- No live platform API calls.
- No credentials.
- No raw targets.
- No mutation authority.
"""

from __future__ import annotations

import argparse
import datetime as _dt
import hashlib
import json
import os
import re
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple

ROOT = Path.cwd()
INDEX_PATH = ROOT / "catalog" / "generated" / "action-index.json"
OUT_ROOT = ROOT / "catalog" / "generated" / "adapters-v1-scaleout"

ADAPTERS = [
    ("ai", "action-contracts.jsonl"),
    ("human", "runbook-index.md"),
    ("ansible", "action-catalog-vars.yml"),
    ("awx", "job-template-candidates.json"),
    ("aws", "ssm-document-candidates.yaml"),
    ("kubernetes", "job-candidates.yaml"),
    ("openshift", "job-candidates.yaml"),
    ("servicenow", "import-set.json"),
    ("cmdb", "ci-evidence-mapping.json"),
    ("gitops", "kustomization-preview.yaml"),
]

REQUIRED_CONTRACT_FIELDS = [
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


def utc_now() -> str:
    return _dt.datetime.now(_dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def read_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8", newline="\n")


def write_json(path: Path, data: Any) -> None:
    write_text(path, json.dumps(data, indent=2, sort_keys=False) + "\n")


def slugify(value: str) -> str:
    s = value.strip().lower()
    s = re.sub(r"[^a-z0-9]+", "-", s)
    return s.strip("-") or "action"


def title_from_path(path: str) -> str:
    name = Path(path).name
    name = re.sub(r"\.ps1$", "", name, flags=re.IGNORECASE)
    name = re.sub(r"^\d+[-_]", "", name)
    return name.replace("-", " ").replace("_", " ").strip().title() or "Evidence Action"


def first_present(mapping: Dict[str, Any], keys: Iterable[str], default: Any = None) -> Any:
    for k in keys:
        if k in mapping and mapping[k] not in (None, ""):
            return mapping[k]
    return default


def extract_number_from_path(path: str) -> Optional[int]:
    name = Path(path).name
    m = re.match(r"^(\d+)[-_]", name)
    if m:
        return int(m.group(1))
    m = re.search(r"[/\\](\d+)[-_][^/\\]+$", path)
    if m:
        return int(m.group(1))
    return None


def lf_normalized_sha256(path: Path) -> str:
    raw = path.read_bytes()
    raw = raw.replace(b"\r\n", b"\n")
    return hashlib.sha256(raw).hexdigest()


def load_actions(index_path: Path) -> Tuple[List[Dict[str, Any]], int]:
    data = read_json(index_path)

    if isinstance(data, list):
        actions = data
    elif isinstance(data, dict):
        actions = None
        for key in ("actions", "items", "records", "data"):
            if isinstance(data.get(key), list):
                actions = data[key]
                break
        if actions is None:
            possible = []
            for value in data.values():
                if isinstance(value, dict):
                    possible.append(value)
            actions = possible if possible else []
    else:
        raise SystemExit(f"unsupported action index JSON root: {type(data).__name__}")

    normalized: List[Dict[str, Any]] = []
    for idx, item in enumerate(actions, start=1):
        if isinstance(item, str):
            normalized.append({"script_path": item})
        elif isinstance(item, dict):
            normalized.append(dict(item))
        else:
            raise SystemExit(f"unsupported action record at index {idx}: {type(item).__name__}")

    return normalized, len(normalized)


def infer_platform(path: str, record: Dict[str, Any]) -> str:
    explicit = first_present(record, ["platform", "os", "target_platform"])
    if explicit:
        return str(explicit)
    low = path.replace("\\", "/").lower()
    if "/windows/" in low or low.endswith(".ps1") or ".cmd" in low:
        return "windows"
    if "/linux/" in low or low.endswith(".sh"):
        return "linux"
    if "/kubernetes/" in low:
        return "kubernetes"
    return "cross_platform"


def infer_persona(path: str, record: Dict[str, Any]) -> str:
    explicit = first_present(record, ["persona", "role", "audience"])
    if explicit:
        return str(explicit)
    parts = path.replace("\\", "/").split("/")
    if "end-user" in parts:
        return "end_user"
    if "storage-admin" in parts:
        return "storage_admin"
    if "network-admin" in parts:
        return "network_admin"
    return "operator"


def infer_domain(path: str, record: Dict[str, Any]) -> str:
    explicit = first_present(record, ["domain"])
    if explicit:
        return str(explicit)
    low = path.lower()
    if "storage" in low or "smb" in low or "dfs" in low or "vss" in low or "backup" in low:
        return "storage"
    if "network" in low or "dns" in low or "firewall" in low:
        return "network"
    if "security" in low or "ransomware" in low or "varonis" in low:
        return "security"
    if "kubernetes" in low or "openshift" in low:
        return "platform"
    return "operations"


def normalize_action(record: Dict[str, Any], index: int, now: str) -> Dict[str, Any]:
    path = str(first_present(record, [
        "script_path",
        "path",
        "file",
        "filepath",
        "relative_path",
        "source_path",
        "check_path",
    ], ""))

    if not path:
        raise SystemExit(f"action at source index {index} has no script path")

    extracted_number = extract_number_from_path(path)
    raw_number = first_present(record, ["action_number", "number", "id_number", "sequence", "script_number"], extracted_number)
    if raw_number is None:
        raw_number = index

    try:
        action_number = int(raw_number)
    except Exception as exc:
        raise SystemExit(f"invalid action number for {path}: {raw_number}") from exc

    title = str(first_present(record, ["title", "name", "action_title"], title_from_path(path))).strip()
    action_id = str(first_present(record, ["action_id", "id", "ActionId"], "")).strip()
    if not action_id:
        action_id = f"action-{action_number:04d}-{slugify(title)}"

    script_file = ROOT / path
    script_sha = str(first_present(record, ["script_sha256", "sha256", "hash"], "")).strip()
    if not script_sha:
        if script_file.exists():
            script_sha = lf_normalized_sha256(script_file)
        else:
            raise SystemExit(f"missing script sha256 and file not found: {path}")

    platform = infer_platform(path, record)
    persona = infer_persona(path, record)
    domain = infer_domain(path, record)
    subdomain = str(first_present(record, ["subdomain"], "evidence")).strip()
    category = str(first_present(record, ["category"], "evidence_collection")).strip()
    support_level = str(first_present(record, ["support_level"], "tier1_to_tier3")).strip()

    contract = {
        "schema_version": "action-contract.v1",
        "action_number": action_number,
        "action_id": action_id,
        "title": title,
        "description": str(first_present(record, ["description", "summary"], f"Evidence-only action for {title}.")).strip(),
        "domain": domain,
        "subdomain": subdomain,
        "category": category,
        "platform": platform,
        "persona": persona,
        "support_level": support_level,
        "authority_required": "operator_review",
        "safety_class": "evidence_only",
        "mutation_allowed": False,
        "approval_required": False,
        "secret_policy": "no_secrets",
        "target_policy": "no_raw_targets",
        "network_scan_allowed": False,
        "runtime_context": {
            "shell": "powershell" if path.lower().endswith(".ps1") else "unknown",
            "execution_mode": "preview_projection_only",
            "live_platform_api_calls": False,
        },
        "script_path": path.replace("\\", "/"),
        "script_sha256": script_sha.lower(),
        "hash_policy": "lf-normalized-sha256",
        "inputs": [],
        "outputs": [
            "sanitized_stdout",
            "sanitized_stderr",
            "exit_code",
            "evidence_summary",
        ],
        "evidence_contract": {
            "collection_type": "read_only_or_guidance",
            "ticket_ready": True,
            "mutation_authority": "not_granted",
            "approval_authority": "not_granted",
        },
        "sanitization_policy": {
            "preserve": ["action_id", "action_number", "title", "script_sha256", "category"],
            "redact": ["secrets", "tokens", "passwords", "raw_targets", "raw_hostnames", "raw_user_identifiers"],
            "secret_scanning_required": True,
        },
        "adapter_hints": {
            "ansible": "vars_only_preview",
            "awx": "job_template_candidate_preview",
            "aws_ssm": "document_candidate_preview",
            "kubernetes": "custom_resource_candidate_preview",
            "openshift": "custom_resource_candidate_preview",
            "servicenow": "import_set_candidate_preview",
            "cmdb": "candidate_mapping_not_authoritative",
            "gitops": "preview_artifact_only",
            "ai": "explain_select_recommend_only",
            "human": "runbook_index_only",
        },
        "status": "preview_exported",
        "accepted_for_baseline": True,
        "accepted_for_mutation": False,
        "created_utc": str(first_present(record, ["created_utc", "created"], now)),
        "updated_utc": now,
    }

    missing = [field for field in REQUIRED_CONTRACT_FIELDS if field not in contract]
    if missing:
        raise SystemExit(f"contract generation bug, missing {missing} for {path}")

    return contract


def yaml_scalar(value: Any) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int):
        return str(value)
    if value is None:
        return "null"
    return json.dumps(str(value))


def write_ansible(actions: List[Dict[str, Any]], path: Path) -> None:
    lines = [
        "---",
        "novak_action_catalog:",
        '  schema_version: "adapter-export-layer-v1-scaleout"',
        "  mutation_allowed: false",
        "  live_platform_api_calls: false",
        "  actions:",
    ]
    for a in actions:
        lines.extend([
            "    - action_id: " + yaml_scalar(a["action_id"]),
            "      action_number: " + str(a["action_number"]),
            "      title: " + yaml_scalar(a["title"]),
            "      platform: " + yaml_scalar(a["platform"]),
            "      safety_class: " + yaml_scalar(a["safety_class"]),
            "      mutation_allowed: false",
            "      script_path: " + yaml_scalar(a["script_path"]),
            "      script_sha256: " + yaml_scalar(a["script_sha256"]),
        ])
    write_text(path, "\n".join(lines) + "\n")


def write_ssm(actions: List[Dict[str, Any]], path: Path) -> None:
    lines = [
        "---",
        'schema_version: "adapter-export-layer-v1-scaleout"',
        'adapter: "aws_ssm_document_candidates"',
        "mutation_allowed: false",
        "live_platform_api_calls: false",
        "documents:",
    ]
    for a in actions:
        name = f"NOVAK-Evidence-{a['action_number']}"
        lines.extend([
            "  - name: " + yaml_scalar(name),
            "    action_id: " + yaml_scalar(a["action_id"]),
            "    action_number: " + str(a["action_number"]),
            "    document_type: " + yaml_scalar("CommandCandidatePreview"),
            "    platform: " + yaml_scalar(a["platform"]),
            "    safety_class: " + yaml_scalar(a["safety_class"]),
            "    mutation_allowed: false",
            "    script_path: " + yaml_scalar(a["script_path"]),
            "    script_sha256: " + yaml_scalar(a["script_sha256"]),
        ])
    write_text(path, "\n".join(lines) + "\n")


def write_custom_resource_candidates(actions: List[Dict[str, Any]], path: Path, adapter: str) -> None:
    lines = [
        "---",
        "apiVersion: novakprotocol.io/v1alpha1",
        "kind: EvidenceActionCandidateList",
        "metadata:",
        "  name: novak-action-catalog-evidence-candidates",
        "spec:",
        "  adapter: " + yaml_scalar(adapter),
        "  mutationAllowed: false",
        "  livePlatformApiCalls: false",
        "  actions:",
    ]
    for a in actions:
        lines.extend([
            "    - actionId: " + yaml_scalar(a["action_id"]),
            "      actionNumber: " + str(a["action_number"]),
            "      title: " + yaml_scalar(a["title"]),
            "      platform: " + yaml_scalar(a["platform"]),
            "      safetyClass: " + yaml_scalar(a["safety_class"]),
            "      mutationAllowed: false",
            "      scriptPath: " + yaml_scalar(a["script_path"]),
            "      scriptSha256: " + yaml_scalar(a["script_sha256"]),
        ])
    write_text(path, "\n".join(lines) + "\n")


def write_gitops_preview(actions: List[Dict[str, Any]], path: Path) -> None:
    lines = [
        "---",
        "apiVersion: kustomize.config.k8s.io/v1beta1",
        "kind: Kustomization",
        "metadata:",
        "  name: novak-action-catalog-adapter-preview",
        "commonLabels:",
        "  novakprotocol.io/export-layer: adapter-v1-scaleout",
        "configMapGenerator:",
        "  - name: novak-action-catalog-adapter-preview",
        "    literals:",
        "      - mutation_allowed=false",
        "      - live_platform_api_calls=false",
        f"      - exported_actions={len(actions)}",
        "      - source=catalog/generated/action-index.json",
    ]
    write_text(path, "\n".join(lines) + "\n")


def make_awx(actions: List[Dict[str, Any]]) -> Dict[str, Any]:
    return {
        "schema_version": "adapter-export-layer-v1-scaleout",
        "adapter": "awx_job_template_candidates",
        "mutation_allowed": False,
        "live_platform_api_calls": False,
        "templates": [
            {
                "name": f"NOVAK Evidence {a['action_number']} - {a['title'][:80]}",
                "description": a["description"],
                "action_id": a["action_id"],
                "action_number": a["action_number"],
                "job_type": "run",
                "check_mode_default": True,
                "diff_mode_default": False,
                "credential_required": False,
                "variables": {
                    "novak_action_id": a["action_id"],
                    "novak_script_path": a["script_path"],
                    "novak_script_sha256": a["script_sha256"],
                    "novak_mutation_allowed": False,
                },
            }
            for a in actions
        ],
    }


def make_servicenow(actions: List[Dict[str, Any]]) -> Dict[str, Any]:
    return {
        "schema_version": "adapter-export-layer-v1-scaleout",
        "adapter": "servicenow_import_set_candidate_preview",
        "mutation_allowed": False,
        "live_platform_api_calls": False,
        "records": [
            {
                "u_action_id": a["action_id"],
                "u_action_number": a["action_number"],
                "u_title": a["title"],
                "u_description": a["description"],
                "u_domain": a["domain"],
                "u_category": a["category"],
                "u_platform": a["platform"],
                "u_safety_class": a["safety_class"],
                "u_script_path": a["script_path"],
                "u_script_sha256": a["script_sha256"],
                "u_auto_assign": False,
                "u_auto_close": False,
                "u_auto_priority": False,
                "u_change_approval_created": False,
            }
            for a in actions
        ],
    }


def make_cmdb(actions: List[Dict[str, Any]]) -> Dict[str, Any]:
    return {
        "schema_version": "adapter-export-layer-v1-scaleout",
        "adapter": "cmdb_candidate_mapping_preview",
        "mutation_allowed": False,
        "authoritative_ci_update": False,
        "live_platform_api_calls": False,
        "mappings": [
            {
                "action_id": a["action_id"],
                "action_number": a["action_number"],
                "candidate_ci_class": "service_or_infrastructure_component",
                "domain": a["domain"],
                "subdomain": a["subdomain"],
                "platform": a["platform"],
                "evidence_fields": {
                    "script_path": a["script_path"],
                    "script_sha256": a["script_sha256"],
                    "safety_class": a["safety_class"],
                    "mutation_allowed": a["mutation_allowed"],
                },
                "asserts_ownership": False,
                "asserts_environment": False,
                "asserts_service_criticality": False,
            }
            for a in actions
        ],
    }


def write_human(actions: List[Dict[str, Any]], path: Path) -> None:
    lines = [
        "# NOVAK Action Catalog - Adapter Export Layer v1 Scaleout Runbook Index",
        "",
        "This is a generated, evidence-only preview index.",
        "",
        "- No mutation authority",
        "- No credentials",
        "- No raw target lists",
        "- No live platform calls",
        "- No remediation",
        "",
        "| # | Action ID | Title | Platform | Script |",
        "|---:|---|---|---|---|",
    ]
    for a in actions:
        title = a["title"].replace("|", "/")
        lines.append(f"| {a['action_number']} | `{a['action_id']}` | {title} | {a['platform']} | `{a['script_path']}` |")
    write_text(path, "\n".join(lines) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--index", default=str(INDEX_PATH))
    parser.add_argument("--out-root", default=str(OUT_ROOT))
    parser.add_argument("--export-limit", type=int, default=0, help="0 means all actions")
    args = parser.parse_args()

    index_path = Path(args.index)
    out_root = Path(args.out_root)

    if not index_path.exists():
        raise SystemExit(f"missing action index: {index_path}")

    now = utc_now()
    raw_actions, source_count = load_actions(index_path)
    if source_count <= 0:
        raise SystemExit("no actions found in action index")

    selected_raw = raw_actions if args.export_limit <= 0 else raw_actions[: args.export_limit]
    contracts = [normalize_action(record, i + 1, now) for i, record in enumerate(selected_raw)]

    out_root.mkdir(parents=True, exist_ok=True)

    # AI contract JSONL.
    ai_path = out_root / "ai" / "action-contracts.jsonl"
    write_text(ai_path, "".join(json.dumps(a, sort_keys=True) + "\n" for a in contracts))

    # Human.
    write_human(contracts, out_root / "human" / "runbook-index.md")

    # Ansible/AWS/K8s/OpenShift/GitOps YAML.
    write_ansible(contracts, out_root / "ansible" / "action-catalog-vars.yml")
    write_ssm(contracts, out_root / "aws" / "ssm-document-candidates.yaml")
    write_custom_resource_candidates(contracts, out_root / "kubernetes" / "job-candidates.yaml", "kubernetes")
    write_custom_resource_candidates(contracts, out_root / "openshift" / "job-candidates.yaml", "openshift")
    write_gitops_preview(contracts, out_root / "gitops" / "kustomization-preview.yaml")

    # JSON platform projections.
    write_json(out_root / "awx" / "job-template-candidates.json", make_awx(contracts))
    write_json(out_root / "servicenow" / "import-set.json", make_servicenow(contracts))
    write_json(out_root / "cmdb" / "ci-evidence-mapping.json", make_cmdb(contracts))

    manifest = {
        "schema_version": "adapter-manifest.v1",
        "export_layer": "adapter-export-layer-v1-scaleout",
        "generated_utc": now,
        "source_index": "catalog/generated/action-index.json",
        "source_actions": source_count,
        "exported_actions": len(contracts),
        "export_limit": args.export_limit,
        "mutation_allowed": False,
        "approval_authority_granted": False,
        "secret_policy": "no_secrets",
        "target_policy": "no_raw_targets",
        "network_scan_allowed": False,
        "live_platform_api_calls": False,
        "adapters": [
            {
                "name": name,
                "path": f"catalog/generated/adapters-v1-scaleout/{name}/{file}",
                "exported_actions": len(contracts),
                "boundary": "preview_projection_only",
            }
            for name, file in ADAPTERS
        ],
    }
    write_json(out_root / "adapter-manifest.json", manifest)

    print(f"PASS generate_adapter_exports_v1_scaleout source_actions={source_count} exported_actions={len(contracts)} adapters={len(ADAPTERS)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())