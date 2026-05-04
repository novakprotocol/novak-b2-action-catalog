#!/usr/bin/env python3
"""
validate_adapter_release_inventory.py

Recomputes hashes from catalog/releases/adapter-export-layer-v1-scaleout-file-inventory.sha256.json.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--inventory", default="catalog/releases/adapter-export-layer-v1-scaleout-file-inventory.sha256.json")
    args = parser.parse_args()

    repo = Path.cwd()
    inventory_path = repo / args.inventory
    if not inventory_path.exists():
        raise SystemExit(f"FAIL validate_adapter_release_inventory missing_inventory={args.inventory}")

    payload = json.loads(inventory_path.read_text(encoding="utf-8-sig"))
    files = payload.get("files", [])
    if not isinstance(files, list) or not files:
        raise SystemExit("FAIL validate_adapter_release_inventory empty_files")

    for entry in files:
        rel = entry.get("path")
        expected = entry.get("sha256")
        if not rel or not expected:
            raise SystemExit(f"FAIL validate_adapter_release_inventory malformed_entry={entry}")
        path = repo / rel
        if not path.exists():
            raise SystemExit(f"FAIL validate_adapter_release_inventory missing_file={rel}")
        actual = sha256_file(path)
        if actual.lower() != str(expected).lower():
            raise SystemExit(f"FAIL validate_adapter_release_inventory sha_mismatch path={rel}")

    print(f"PASS validate_adapter_release_inventory files={len(files)}")


if __name__ == "__main__":
    main()
