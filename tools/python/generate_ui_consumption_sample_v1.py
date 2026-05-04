#!/usr/bin/env python3
import argparse
import hashlib
import html
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "catalog" / "generated" / "adapters-v1-scaleout" / "ai" / "action-contracts.jsonl"
OUT_DIR = ROOT / "catalog" / "generated" / "ui-consumption-sample-v1"
SAMPLE_JSON = OUT_DIR / "actions.sample.json"
SAMPLE_HTML = OUT_DIR / "index.html"
REPORT = ROOT / "catalog" / "releases" / "ui-consumption-sample-v1-report.json"

ADAPTERS = [
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
]


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8-sig") as f:
        for line_number, line in enumerate(f, start=1):
            text = line.strip()
            if not text:
                continue
            try:
                value = json.loads(text)
            except json.JSONDecodeError as exc:
                raise SystemExit(f"FAIL invalid jsonl line={line_number} error={exc}") from exc
            if not isinstance(value, dict):
                raise SystemExit(f"FAIL jsonl line is not object line={line_number}")
            rows.append(value)
    return rows


def dict_get_casefold(obj: dict[str, Any], key: str) -> Any:
    if key in obj:
        return obj[key]
    wanted = key.casefold()
    for existing_key, value in obj.items():
        if existing_key.casefold() == wanted:
            return value
    return None


def deep_get(obj: dict[str, Any], candidates: list[str]) -> Any:
    for candidate in candidates:
        current: Any = obj
        ok = True
        for part in candidate.split("."):
            if isinstance(current, dict):
                current = dict_get_casefold(current, part)
            else:
                ok = False
                break
            if current is None:
                ok = False
                break
        if ok and current not in (None, ""):
            return current
    return None


def safe_text(value: Any, fallback: str) -> str:
    if value is None:
        return fallback
    text = str(value).replace("\r", " ").replace("\n", " ").strip()
    if not text:
        return fallback
    if len(text) > 180:
        text = text[:177] + "..."
    return text


def build_item(row: dict[str, Any], index: int) -> dict[str, Any]:
    action_id = safe_text(
        deep_get(row, ["action_id", "actionId", "id", "metadata.action_id", "metadata.actionId", "action.id"]),
        f"action-{index:04d}",
    )
    action_number = safe_text(
        deep_get(row, ["action_number", "actionNumber", "number", "metadata.action_number", "metadata.number"]),
        str(index),
    )
    title = safe_text(
        deep_get(row, ["title", "name", "summary", "display_name", "displayName", "action_name", "metadata.title"]),
        action_id,
    )
    layer = safe_text(
        deep_get(row, ["layer", "action_layer", "actionLayer", "category", "metadata.layer", "metadata.category"]),
        "unknown",
    )
    source_path = safe_text(
        deep_get(row, ["script_path", "source_path", "sourcePath", "path", "file", "metadata.path"]),
        "",
    )
    return {
        "action_id": action_id,
        "action_number": action_number,
        "title": title,
        "layer": layer,
        "source_path": source_path,
        "adapter_ready": True,
        "mutation_authority": False,
        "live_platform_call": False,
        "display_boundary": "browse-only; no execution; no credentials; no live platform calls",
    }


def render_html(payload: dict[str, Any]) -> str:
    rows: list[str] = []
    for item in payload["items"]:
        rows.append(
            "<tr>"
            f"<td>{html.escape(item['action_number'])}</td>"
            f"<td>{html.escape(item['action_id'])}</td>"
            f"<td>{html.escape(item['title'])}</td>"
            f"<td>{html.escape(item['layer'])}</td>"
            f"<td>{html.escape(', '.join(payload['adapters']))}</td>"
            f"<td>{html.escape(item['display_boundary'])}</td>"
            "</tr>"
        )

    return """<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>NOVAK Action Catalog UI Consumption Sample v1</title>
  <style>
    body { font-family: system-ui, sans-serif; margin: 2rem; line-height: 1.4; }
    table { border-collapse: collapse; width: 100%; margin-top: 1rem; }
    th, td { border: 1px solid #999; padding: 0.45rem; vertical-align: top; }
    th { text-align: left; }
    code { white-space: nowrap; }
    .boundary { border: 1px solid #999; padding: 0.75rem; margin: 1rem 0; }
  </style>
</head>
<body data-sample-boundary="browse-only">
  <h1>NOVAK Action Catalog UI Consumption Sample v1</h1>
  <div class="boundary">
    <strong>Boundary:</strong>
    Static browse-only projection. No execution. No credentials. No network calls. No live platform API calls.
  </div>
  <p>
    Source actions: <code>""" + html.escape(str(payload["source_actions"])) + """</code><br>
    Sample actions: <code>""" + html.escape(str(payload["sample_actions"])) + """</code><br>
    Adapters: <code>""" + html.escape(", ".join(payload["adapters"])) + """</code>
  </p>
  <table aria-label="Action Catalog UI consumption sample">
    <thead>
      <tr>
        <th>Number</th>
        <th>Action ID</th>
        <th>Title</th>
        <th>Layer</th>
        <th>Adapters</th>
        <th>Boundary</th>
      </tr>
    </thead>
    <tbody>
""" + "\n".join(rows) + """
    </tbody>
  </table>
</body>
</html>
"""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--sample-size", type=int, default=50)
    parser.add_argument("--expected-actions", type=int, default=5000)
    parser.add_argument("--expected-adapters", type=int, default=10)
    args = parser.parse_args()

    if args.sample_size < 1:
        raise SystemExit("FAIL sample-size must be positive")

    if not SOURCE.exists():
        raise SystemExit(f"FAIL missing source jsonl path={SOURCE}")

    rows = load_jsonl(SOURCE)
    if len(rows) != args.expected_actions:
        raise SystemExit(f"FAIL source action count expected={args.expected_actions} actual={len(rows)}")

    if len(ADAPTERS) != args.expected_adapters:
        raise SystemExit(f"FAIL adapter count expected={args.expected_adapters} actual={len(ADAPTERS)}")

    items = [build_item(row, i + 1) for i, row in enumerate(rows[: args.sample_size])]

    payload = {
        "schema_version": "ui-consumption-sample.v1",
        "generation_mode": "deterministic",
        "source": "catalog/generated/adapters-v1-scaleout/ai/action-contracts.jsonl",
        "source_sha256": sha256_file(SOURCE),
        "source_actions": len(rows),
        "sample_actions": len(items),
        "adapters": ADAPTERS,
        "boundary": {
            "browse_only": True,
            "mutation_authority": False,
            "live_platform_calls": False,
            "credentials": False,
            "network_calls": False,
        },
        "items": items,
    }

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    REPORT.parent.mkdir(parents=True, exist_ok=True)

    SAMPLE_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    SAMPLE_HTML.write_text(render_html(payload), encoding="utf-8")

    report = {
        "result": "PASS",
        "schema_version": "ui-consumption-sample-report.v1",
        "source_actions": len(rows),
        "sample_actions": len(items),
        "adapters": len(ADAPTERS),
        "files": [
            "catalog/generated/ui-consumption-sample-v1/actions.sample.json",
            "catalog/generated/ui-consumption-sample-v1/index.html",
        ],
        "boundary": payload["boundary"],
        "sample_json_sha256": sha256_file(SAMPLE_JSON),
        "sample_html_sha256": sha256_file(SAMPLE_HTML),
    }
    REPORT.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    print(
        "PASS generate_ui_consumption_sample_v1 "
        f"source_actions={len(rows)} sample_actions={len(items)} adapters={len(ADAPTERS)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
