#!/usr/bin/env python3
import argparse
import json
import sys
from pathlib import Path

REQUIRED_PATHS = {
    "catalog/generated/adapters-v1-scaleout/ai/action-contracts.jsonl",
    "catalog/generated/adapters-v1-scaleout/adapter-manifest.json",
    "catalog/releases/adapter-export-layer-v1-scaleout-accepted-baseline.json",
    "catalog/releases/adapter-export-layer-v1-scaleout-file-inventory.sha256.json",
    "catalog/releases/adapter-consumption-smoke-v1-report.json",
    "tools/python/validate_adapter_consumption_smoke_v1.py",
}

REQUIRED_CLASSES = {
    "bounded_preview_export",
    "scaleout_export",
    "release_evidence",
    "operator_documentation",
    "validation_or_generation_tool",
}

def fail(message: str) -> None:
    print(f"FAIL validate_adapter_export_package_index_v1 {message}", file=sys.stderr)
    raise SystemExit(1)

def load(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8-sig"))
    except Exception as exc:
        fail(f"json_parse_failed file={path.as_posix()} error={exc}")

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--index", default="catalog/releases/adapter-export-package-index-v1.json")
    parser.add_argument("--expected-actions", type=int, default=5000)
    parser.add_argument("--expected-adapters", type=int, default=10)
    args = parser.parse_args()

    root = Path(".").resolve()
    index_path = root / args.index
    if not index_path.exists():
        fail(f"missing_index file={args.index}")

    data = load(index_path)

    if data.get("schema_version") != "adapter-export-package-index-v1":
        fail(f"schema_version actual={data.get('schema_version')!r}")

    if data.get("expected_actions") != args.expected_actions:
        fail(f"expected_actions actual={data.get('expected_actions')} expected={args.expected_actions}")

    if data.get("expected_adapters") != args.expected_adapters:
        fail(f"expected_adapters actual={data.get('expected_adapters')} expected={args.expected_adapters}")

    boundary = data.get("boundary")
    if not isinstance(boundary, dict):
        fail("missing_boundary")
    for key in (
        "index_only",
        "no_live_platform_api_calls",
        "no_remediation",
        "no_credentials",
        "no_secrets",
        "no_raw_targets",
        "does_not_modify_generated_adapter_outputs",
    ):
        if boundary.get(key) is not True:
            fail(f"boundary_not_true key={key}")

    files = data.get("files")
    if not isinstance(files, list):
        fail("files_not_list")

    counts = data.get("counts")
    if not isinstance(counts, dict):
        fail("missing_counts")

    if counts.get("files_indexed") != len(files):
        fail(f"files_indexed_mismatch counts={counts.get('files_indexed')} actual={len(files)}")

    missing = data.get("missing")
    if missing:
        fail(f"missing_files count={len(missing)} files={missing}")

    paths = {item.get("path") for item in files if isinstance(item, dict)}
    missing_required = sorted(REQUIRED_PATHS - paths)
    if missing_required:
        fail(f"missing_required_paths files={missing_required}")

    classes = {item.get("class") for item in files if isinstance(item, dict)}
    missing_classes = sorted(REQUIRED_CLASSES - classes)
    if missing_classes:
        fail(f"missing_required_classes classes={missing_classes}")

    for item in files:
        if not isinstance(item, dict):
            fail("file_entry_not_dict")
        path = item.get("path")
        if not isinstance(path, str) or not path:
            fail("file_entry_missing_path")
        actual = root / path
        if not actual.exists():
            fail(f"indexed_file_missing_on_disk file={path}")
        if not isinstance(item.get("sha256"), str) or len(item["sha256"]) != 64:
            fail(f"bad_sha256 file={path}")
        if not isinstance(item.get("bytes"), int) or item["bytes"] <= 0:
            fail(f"bad_bytes file={path}")
        if not isinstance(item.get("lines"), int) or item["lines"] < 0:
            fail(f"bad_lines file={path}")

    print(
        "PASS validate_adapter_export_package_index_v1 "
        f"files={len(files)} "
        f"actions={args.expected_actions} "
        f"adapters={args.expected_adapters}"
    )
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
