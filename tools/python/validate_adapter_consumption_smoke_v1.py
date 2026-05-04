#!/usr/bin/env python3
import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

FORBIDDEN_COMMAND_PATTERNS = [
    re.compile(r"^\s*(Restart-Service|Stop-Service|Start-Service|Remove-Item|Set-Acl|icacls|format-volume|Clear-Disk|Initialize-Disk|New-Partition|Remove-Partition|Restart-Computer)\b", re.I | re.M),
    re.compile(r"^\s*(shutdown|reboot)(?:\.exe)?\s+[-/]", re.I | re.M),
    re.compile(r"^\s*(kubectl|oc)\s+(apply|delete|patch|scale|rollout|cordon|drain|adm)\b", re.I | re.M),
    re.compile(r"^\s*helm\s+(install|upgrade|uninstall|delete)\b", re.I | re.M),
    re.compile(r"^\s*aws\b.{0,120}\b(delete|terminate|stop|start|modify|put-|attach|detach|create|update)\b", re.I | re.M),
    re.compile(r"^\s*az\b.{0,120}\b(delete|create|update|set)\b", re.I | re.M),
]

SECRET_RE = re.compile(
    r"password\s*[:=]\s*['\"]?[^'\"\s]+|"
    r"secret\s*[:=]\s*['\"]?[^'\"\s]+|"
    r"token\s*[:=]\s*['\"]?[^'\"\s]+|"
    r"api[_-]?key\s*[:=]\s*['\"]?[^'\"\s]+|"
    r"private[_-]?key|"
    r"BEGIN RSA PRIVATE KEY|BEGIN OPENSSH PRIVATE KEY",
    re.I | re.M,
)

RAW_TARGET_RE = re.compile(
    r"^\s*(target|host|server|endpoint|computer|ip|address)\s*[:=]\s*("
    r"\b(?:(?:25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(?:25[0-5]|2[0-4]\d|1?\d?\d)\b|"
    r"[A-Za-z]:\\|"
    r"\\\\[A-Za-z0-9_.-]+\\[A-Za-z0-9_$.-]+"
    r")",
    re.I | re.M,
)

REQUIRED_FILES = [
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
]

JSON_FILES = [
    "catalog/generated/adapters-v1-scaleout/adapter-manifest.json",
    "catalog/generated/adapters-v1-scaleout/awx/job-template-candidates.json",
    "catalog/generated/adapters-v1-scaleout/servicenow/import-set.json",
    "catalog/generated/adapters-v1-scaleout/cmdb/ci-evidence-mapping.json",
    "catalog/releases/adapter-export-layer-v1-scaleout-accepted-baseline.json",
    "catalog/releases/adapter-export-layer-v1-scaleout-file-inventory.sha256.json",
]

TEXT_PROJECTION_FILES = [
    "catalog/generated/adapters-v1-scaleout/human/runbook-index.md",
    "catalog/generated/adapters-v1-scaleout/ansible/action-catalog-vars.yml",
    "catalog/generated/adapters-v1-scaleout/aws/ssm-document-candidates.yaml",
    "catalog/generated/adapters-v1-scaleout/kubernetes/job-candidates.yaml",
    "catalog/generated/adapters-v1-scaleout/openshift/job-candidates.yaml",
    "catalog/generated/adapters-v1-scaleout/gitops/kustomization-preview.yaml",
]

def fail(message: str) -> None:
    print(f"FAIL validate_adapter_consumption_smoke_v1 {message}", file=sys.stderr)
    raise SystemExit(1)

def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8-sig")
    except UnicodeDecodeError:
        return path.read_text(encoding="utf-8")

def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def load_json(path: Path):
    try:
        return json.loads(read_text(path))
    except Exception as exc:
        fail(f"json_parse_failed file={path.as_posix()} error={exc}")

def walk(obj):
    if isinstance(obj, dict):
        yield obj
        for value in obj.values():
            yield from walk(value)
    elif isinstance(obj, list):
        for item in obj:
            yield from walk(item)

def collect_action_ids(obj):
    found = []
    for node in walk(obj):
        for key in ("action_id", "source_action_id", "id"):
            value = node.get(key)
            if isinstance(value, str) and value:
                if key in ("action_id", "source_action_id") or value.startswith("AC-") or "action" in value.lower():
                    found.append(value)
                    break
    return found

def check_no_unsafe_content(path: Path, body: str) -> None:
    # Command-shaped patterns only. Harmless prose like "Reboot guidance" is allowed.
    for pattern in FORBIDDEN_COMMAND_PATTERNS:
        match = pattern.search(body)
        if match:
            fail(f"forbidden_command_shaped_mutation_or_live_operation file={path.as_posix()} match={match.group(0)!r}")

    match = SECRET_RE.search(body)
    if match:
        fail(f"secret_like_content file={path.as_posix()} match={match.group(0)!r}")

    match = RAW_TARGET_RE.search(body)
    if match:
        fail(f"raw_target_like_content file={path.as_posix()} match={match.group(0)!r}")

def validate_jsonl(path: Path, expected_actions: int) -> dict:
    ids = []
    line_count = 0

    for line in read_text(path).splitlines():
        if not line.strip():
            continue

        line_count += 1
        try:
            obj = json.loads(line)
        except Exception as exc:
            fail(f"jsonl_parse_failed file={path.as_posix()} line={line_count} error={exc}")

        action_id = obj.get("action_id") or obj.get("source_action_id")
        if not isinstance(action_id, str) or not action_id:
            fail(f"jsonl_missing_action_id file={path.as_posix()} line={line_count}")

        ids.append(action_id)

        if obj.get("mutation_allowed") not in (False, "false", "False", 0):
            fail(f"jsonl_mutation_allowed_not_false line={line_count} action_id={action_id}")

    if line_count != expected_actions:
        fail(f"jsonl_line_count expected={expected_actions} actual={line_count}")

    if len(set(ids)) != expected_actions:
        fail(f"jsonl_unique_action_id_count expected={expected_actions} actual={len(set(ids))}")

    return {"line_count": line_count, "unique_action_ids": len(set(ids))}

def validate_text_projection(path: Path, rel: str, body: str, expected_actions: int) -> dict:
    line_count = len(body.splitlines())
    if line_count < 3:
        fail(f"text_projection_too_short file={rel} lines={line_count}")

    if rel.endswith("gitops/kustomization-preview.yaml"):
        if "kind: Kustomization" not in body:
            fail(f"gitops_kustomization_missing_kind file={rel}")
        if "resources:" not in body and "configMapGenerator:" not in body:
            fail(f"gitops_kustomization_missing_resources_or_configmapgenerator file={rel}")
        if f"exported_actions={expected_actions}" not in body:
            fail(f"gitops_kustomization_missing_exported_actions_literal file={rel}")

    return {
        "line_count": line_count,
        "bytes": path.stat().st_size,
        "sha256": sha256_file(path),
        "consumption_shape": "safe text projection; canonical all-action count is proven by ai/action-contracts.jsonl",
    }

def compare_existing_report(report: dict, out_path: Path) -> None:
    if not out_path.exists():
        fail(f"missing_existing_report file={out_path.as_posix()} run_with=--update-report")

    try:
        existing = json.loads(read_text(out_path))
    except Exception as exc:
        fail(f"existing_report_parse_failed file={out_path.as_posix()} error={exc}")

    if existing != report:
        fail(f"existing_report_semantic_drift file={out_path.as_posix()} run_with=--update-report")

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--expected-actions", type=int, default=5000)
    parser.add_argument("--expected-adapters", type=int, default=10)
    parser.add_argument(
        "--write-report",
        default="catalog/releases/adapter-consumption-smoke-v1-report.json",
        help="Report path. Default mode checks this tracked report without rewriting it.",
    )
    parser.add_argument(
        "--update-report",
        action="store_true",
        help="Rewrite the tracked report. Omit this for read-only validation.",
    )
    args = parser.parse_args()

    root = Path(".").resolve()
    report = {
        "schema_version": "adapter-consumption-smoke-v1",
        "expected_actions": args.expected_actions,
        "expected_adapters": args.expected_adapters,
        "files_checked": [],
        "json_files": {},
        "jsonl_files": {},
        "text_projection_files": {},
        "boundary_checks": {
            "plain_reboot_word_allowed": True,
            "text_projection_action_id_repetition_not_required": True,
            "gitops_kustomization_allows_configmapgenerator_preview": True,
            "no_command_shaped_mutation_or_live_platform_operations": True,
            "no_secret_like_content": True,
            "no_raw_target_like_content": True,
        },
    }

    for rel in REQUIRED_FILES:
        path = root / rel
        if not path.exists():
            fail(f"missing_required_file file={rel}")
        if path.stat().st_size == 0:
            fail(f"empty_required_file file={rel}")

        body = read_text(path)
        check_no_unsafe_content(path, body)

        report["files_checked"].append({
            "path": rel,
            "bytes": path.stat().st_size,
            "sha256": sha256_file(path),
        })

    for rel in JSON_FILES:
        obj = load_json(root / rel)
        ids = collect_action_ids(obj)
        report["json_files"][rel] = {
            "parsed": True,
            "action_id_occurrences": len(ids),
            "unique_action_ids": len(set(ids)),
        }

    ai_path = root / "catalog/generated/adapters-v1-scaleout/ai/action-contracts.jsonl"
    report["jsonl_files"][ai_path.relative_to(root).as_posix()] = validate_jsonl(ai_path, args.expected_actions)

    for rel in TEXT_PROJECTION_FILES:
        path = root / rel
        body = read_text(path)
        report["text_projection_files"][rel] = validate_text_projection(path, rel, body, args.expected_actions)

    manifest = load_json(root / "catalog/generated/adapters-v1-scaleout/adapter-manifest.json")
    if isinstance(manifest, dict):
        exported = next((manifest.get(k) for k in ("exported_actions", "exported_action_count", "actions") if isinstance(manifest.get(k), int)), None)
        adapters = next((manifest.get(k) for k in ("adapters", "adapter_count") if isinstance(manifest.get(k), int)), None)

        if exported is not None and exported != args.expected_actions:
            fail(f"manifest_exported_actions expected={args.expected_actions} actual={exported}")
        if adapters is not None and adapters != args.expected_adapters:
            fail(f"manifest_adapters expected={args.expected_adapters} actual={adapters}")

    out_path = root / args.write_report
    rendered = json.dumps(report, indent=2, sort_keys=True) + "\n"

    if args.update_report:
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(rendered, encoding="utf-8")
        report_mode = "updated"
    else:
        compare_existing_report(report, out_path)
        report_mode = "checked_read_only"

    print(
        "PASS validate_adapter_consumption_smoke_v1 "
        f"files={len(report['files_checked'])} "
        f"actions={args.expected_actions} "
        f"adapters={args.expected_adapters} "
        f"report_mode={report_mode} "
        f"report={out_path.as_posix()}"
    )
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
