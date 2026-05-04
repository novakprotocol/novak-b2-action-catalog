#!/usr/bin/env python3
"""
generate_adapter_release_inventory.py

Creates a SHA256 inventory for Adapter Export v1 accepted generated files and release docs.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path


DEFAULT_PATHS = [
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
    "docs/ADAPTER_EXPORT_LAYER_V1_ACCEPTED_FLOOR.md",
    "docs/OPERATOR_HANDOFF_ACTION_CATALOG_ADAPTER_EXPORT_V1.md",
    "docs/WHAT_IS_REAL_NOW_ACTION_CATALOG.md",
    "docs/NEXT_ACTIONS_ACTION_CATALOG.md",
]


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default="catalog/releases/adapter-export-layer-v1-scaleout-file-inventory.sha256.json")
    args = parser.parse_args()

    repo = Path.cwd()
    git_head = ""
    try:
        import subprocess
        git_head = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=repo, text=True).strip()
    except Exception:
        git_head = "unknown"

    entries = []
    for rel in DEFAULT_PATHS:
        path = repo / rel
        if not path.exists():
            raise SystemExit(f"FAIL generate_adapter_release_inventory missing={rel}")
        entries.append({
            "path": rel.replace("\\", "/"),
            "size_bytes": path.stat().st_size,
            "sha256": sha256_file(path),
        })

    payload = {
        "schema_version": "adapter_release_file_inventory.v1",
        "created_utc": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "git_head": git_head,
        "file_count": len(entries),
        "files": entries,
    }

    output = repo / args.output
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"PASS generate_adapter_release_inventory files={len(entries)} output={args.output}")


if __name__ == "__main__":
    main()
