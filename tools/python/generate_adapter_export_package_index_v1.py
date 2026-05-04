#!/usr/bin/env python3
import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

PACKAGE_FILES = [
    "catalog/generated/adapters/adapter-manifest.json",
    "catalog/generated/adapters/ai/action-contract.sample.json",
    "catalog/generated/adapters/human/runbook.sample.md",
    "catalog/generated/adapters/ansible/playbook.sample.yml",
    "catalog/generated/adapters/awx/job-template.sample.json",
    "catalog/generated/adapters/aws/ssm-document.sample.yaml",
    "catalog/generated/adapters/servicenow/import-set.sample.json",
    "catalog/generated/adapters/cmdb/ci-evidence-mapping.sample.json",
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
    "catalog/releases/adapter-export-layer-v1-scaleout-file-inventory.sha256.json",
    "catalog/releases/adapter-consumption-smoke-v1-report.json",
    "docs/ADAPTER_EXPORT_LAYER_V1_ACCEPTED_FLOOR.md",
    "docs/OPERATOR_HANDOFF_ACTION_CATALOG_ADAPTER_EXPORT_V1.md",
    "docs/ADAPTER_CONTRACT_HARDENING_V2.md",
    "docs/PLATFORM_CONSUMPTION_BOUNDARY_MATRIX.md",
    "docs/ADAPTER_CONSUMPTION_SMOKE_V1.md",
    "docs/ADAPTER_CONSUMPTION_SMOKE_V1_REPORT.md",
    "docs/ADAPTER_CONSUMPTION_SMOKE_V1B_READONLY.md",
    "docs/ADAPTER_CONSUMPTION_SMOKE_V1B_READONLY_REPORT.md",
    "tools/python/generate_adapter_exports.py",
    "tools/python/validate_adapter_exports.py",
    "tools/python/validate_action_contract_required_fields.py",
    "tools/python/generate_adapter_exports_v1_scaleout.py",
    "tools/python/validate_adapter_exports_v1_scaleout.py",
    "tools/python/validate_adapter_contract_hardening_v2.py",
    "tools/python/generate_adapter_release_inventory.py",
    "tools/python/validate_adapter_release_inventory.py",
    "tools/python/validate_adapter_consumption_smoke_v1.py",
]

def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def line_count(path: Path) -> int:
    try:
        return len(path.read_text(encoding="utf-8-sig").splitlines())
    except UnicodeDecodeError:
        return len(path.read_text(encoding="utf-8", errors="replace").splitlines())

def classify(path: str) -> str:
    if path.startswith("catalog/generated/adapters-v1-scaleout/"):
        return "scaleout_export"
    if path.startswith("catalog/generated/adapters/"):
        return "bounded_preview_export"
    if path.startswith("catalog/releases/"):
        return "release_evidence"
    if path.startswith("docs/"):
        return "operator_documentation"
    if path.startswith("tools/python/"):
        return "validation_or_generation_tool"
    return "other"

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default="catalog/releases/adapter-export-package-index-v1.json")
    parser.add_argument("--expected-actions", type=int, default=5000)
    parser.add_argument("--expected-adapters", type=int, default=10)
    args = parser.parse_args()

    root = Path(".").resolve()
    files = []
    missing = []

    for rel in PACKAGE_FILES:
        path = root / rel
        if not path.exists():
            missing.append(rel)
            continue
        files.append({
            "path": rel,
            "class": classify(rel),
            "bytes": path.stat().st_size,
            "lines": line_count(path),
            "sha256": sha256_file(path),
        })

    out = {
        "schema_version": "adapter-export-package-index-v1",
        "generated_at_utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "expected_actions": args.expected_actions,
        "expected_adapters": args.expected_adapters,
        "boundary": {
            "index_only": True,
            "no_live_platform_api_calls": True,
            "no_remediation": True,
            "no_credentials": True,
            "no_secrets": True,
            "no_raw_targets": True,
            "does_not_modify_generated_adapter_outputs": True,
        },
        "counts": {
            "files_indexed": len(files),
            "missing_files": len(missing),
            "total_bytes": sum(item["bytes"] for item in files),
            "total_lines": sum(item["lines"] for item in files),
        },
        "missing": missing,
        "files": files,
    }

    output = root / args.output
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(out, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"PASS generate_adapter_export_package_index_v1 files={len(files)} missing={len(missing)} output={output.as_posix()}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
