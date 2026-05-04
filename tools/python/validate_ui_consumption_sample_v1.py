#!/usr/bin/env python3
import argparse
import json
import re
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "catalog" / "generated" / "adapters-v1-scaleout" / "ai" / "action-contracts.jsonl"
SAMPLE_JSON = ROOT / "catalog" / "generated" / "ui-consumption-sample-v1" / "actions.sample.json"
SAMPLE_HTML = ROOT / "catalog" / "generated" / "ui-consumption-sample-v1" / "index.html"
REPORT = ROOT / "catalog" / "releases" / "ui-consumption-sample-v1-report.json"

FORBIDDEN_HTML_PATTERNS = [
    re.compile(r"https?://", re.IGNORECASE),
    re.compile(r"<script\b", re.IGNORECASE),
    re.compile(r"\bfetch\s*\(", re.IGNORECASE),
    re.compile(r"\bXMLHttpRequest\b", re.IGNORECASE),
    re.compile(r"<form\b", re.IGNORECASE),
    re.compile(r"\bonclick\s*=", re.IGNORECASE),
    re.compile(r"\bPOST\b", re.IGNORECASE),
    re.compile(r"\bPUT\b", re.IGNORECASE),
    re.compile(r"\bDELETE\b", re.IGNORECASE),
]


def load_json(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(value, dict):
        raise SystemExit(f"FAIL expected json object path={path}")
    return value


def count_jsonl(path: Path) -> int:
    count = 0
    with path.open("r", encoding="utf-8-sig") as f:
        for line in f:
            if line.strip():
                json.loads(line)
                count += 1
    return count


def fail(msg: str) -> None:
    raise SystemExit(f"FAIL validate_ui_consumption_sample_v1 {msg}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--expected-actions", type=int, default=5000)
    parser.add_argument("--expected-adapters", type=int, default=10)
    parser.add_argument("--expected-sample-actions", type=int, default=50)
    args = parser.parse_args()

    for path in [SOURCE, SAMPLE_JSON, SAMPLE_HTML, REPORT]:
        if not path.exists():
            fail(f"missing file={path}")

    source_count = count_jsonl(SOURCE)
    if source_count != args.expected_actions:
        fail(f"source_actions expected={args.expected_actions} actual={source_count}")

    payload = load_json(SAMPLE_JSON)
    report = load_json(REPORT)

    if payload.get("schema_version") != "ui-consumption-sample.v1":
        fail("sample schema_version mismatch")

    if payload.get("source_actions") != args.expected_actions:
        fail(f"sample source_actions expected={args.expected_actions} actual={payload.get('source_actions')}")

    if payload.get("sample_actions") != args.expected_sample_actions:
        fail(f"sample_actions expected={args.expected_sample_actions} actual={payload.get('sample_actions')}")

    adapters = payload.get("adapters")
    if not isinstance(adapters, list) or len(adapters) != args.expected_adapters:
        fail(f"adapters expected={args.expected_adapters} actual={len(adapters) if isinstance(adapters, list) else 'not-list'}")

    boundary = payload.get("boundary")
    if not isinstance(boundary, dict):
        fail("boundary missing")
    expected_false = ["mutation_authority", "live_platform_calls", "credentials", "network_calls"]
    for key in expected_false:
        if boundary.get(key) is not False:
            fail(f"boundary {key} must be false")
    if boundary.get("browse_only") is not True:
        fail("boundary browse_only must be true")

    items = payload.get("items")
    if not isinstance(items, list) or len(items) != args.expected_sample_actions:
        fail("items count mismatch")

    seen: set[str] = set()
    for item in items:
        if not isinstance(item, dict):
            fail("item is not object")
        action_id = item.get("action_id")
        if not isinstance(action_id, str) or not action_id.strip():
            fail("item missing action_id")
        if action_id in seen:
            fail(f"duplicate action_id={action_id}")
        seen.add(action_id)
        if item.get("mutation_authority") is not False:
            fail(f"item mutation_authority not false action_id={action_id}")
        if item.get("live_platform_call") is not False:
            fail(f"item live_platform_call not false action_id={action_id}")

    html_text = SAMPLE_HTML.read_text(encoding="utf-8-sig")
    if 'data-sample-boundary="browse-only"' not in html_text:
        fail("html missing browse-only boundary marker")

    for pattern in FORBIDDEN_HTML_PATTERNS:
        match = pattern.search(html_text)
        if match:
            fail(f"html forbidden pattern match={match.group(0)!r}")

    missing_ids = [action_id for action_id in seen if action_id not in html_text]
    if missing_ids:
        fail(f"html missing sample ids count={len(missing_ids)} first={missing_ids[0]}")

    if report.get("result") != "PASS":
        fail("report result not PASS")
    if report.get("source_actions") != args.expected_actions:
        fail("report source_actions mismatch")
    if report.get("sample_actions") != args.expected_sample_actions:
        fail("report sample_actions mismatch")
    if report.get("adapters") != args.expected_adapters:
        fail("report adapters mismatch")

    print(
        "PASS validate_ui_consumption_sample_v1 "
        f"source_actions={source_count} sample_actions={len(items)} adapters={len(adapters)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
