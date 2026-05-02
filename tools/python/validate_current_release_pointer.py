#!/usr/bin/env python3
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RELEASE_PATH = ROOT / "catalog" / "releases" / "current-accepted-baseline.json"
failures = []

def require(condition, message):
    if not condition:
        failures.append(message)

def rel_exists(relative_path, label):
    require(isinstance(relative_path, str) and relative_path.strip() != "", f"{label} missing or empty")
    if isinstance(relative_path, str) and relative_path.strip() != "":
        require((ROOT / relative_path).exists(), f"{label} path missing: {relative_path}")

require(RELEASE_PATH.exists(), "current accepted baseline file is missing")

if RELEASE_PATH.exists():
    try:
        data = json.loads(RELEASE_PATH.read_text(encoding="utf-8"))
    except Exception as exc:
        failures.append(f"failed to parse current accepted baseline JSON: {exc}")
        data = {}
else:
    data = {}

require(data.get("schema_version") == "1.0", "schema_version must be 1.0")
require(data.get("release_type") == "current_accepted_baseline", "release_type must be current_accepted_baseline")
require(data.get("repo_name") == "novak-b2-action-catalog", "repo_name mismatch")
require(data.get("source_branch") == "main", "source_branch must be main")
require(isinstance(data.get("source_commit"), str) and len(data.get("source_commit", "")) >= 7, "source_commit missing or invalid")
require(data.get("accepted_for_baseline") is True, "accepted_for_baseline must be true")
require(data.get("accepted_for_mutation") is False, "accepted_for_mutation must be false")
require(data.get("privilege_level") == "no-admin", "privilege_level must be no-admin")
require(data.get("credential_required") is False, "credential_required must be false")
require(data.get("target_list_required") is False, "target_list_required must be false")
require(data.get("raw_evidence_in_git") is False, "raw_evidence_in_git must be false")

safety = data.get("safety_boundary", {})
require(safety.get("mutation_approved") is False, "safety_boundary.mutation_approved must be false")
require(safety.get("admin_actions_approved") is False, "safety_boundary.admin_actions_approved must be false")
require(safety.get("enterprise_targeting_approved") is False, "safety_boundary.enterprise_targeting_approved must be false")
require(safety.get("credentials_allowed_in_git") is False, "safety_boundary.credentials_allowed_in_git must be false")
require(safety.get("raw_evidence_allowed_in_git") is False, "safety_boundary.raw_evidence_allowed_in_git must be false")

catalog = data.get("catalog", {})
rel_exists(catalog.get("action_index_json"), "catalog.action_index_json")
rel_exists(catalog.get("action_index_csv"), "catalog.action_index_csv")
rel_exists(catalog.get("catalog_browser"), "catalog.catalog_browser")
rel_exists(catalog.get("current_floor_doc"), "catalog.current_floor_doc")
rel_exists(catalog.get("accepted_baseline_view"), "catalog.accepted_baseline_view")

layers = data.get("approved_action_layers")
require(isinstance(layers, list), "approved_action_layers must be a list")
if isinstance(layers, list):
    require(len(layers) >= 1, "approved_action_layers must contain at least one layer")
    for idx, layer in enumerate(layers):
        require(isinstance(layer, dict), f"layer[{idx}] must be an object")
        if not isinstance(layer, dict):
            continue
        require(layer.get("accepted_for_baseline") is True, f"layer[{idx}].accepted_for_baseline must be true")
        require(layer.get("accepted_for_mutation") is False, f"layer[{idx}].accepted_for_mutation must be false")
        require(layer.get("local_baseline_result") == "PASS", f"layer[{idx}].local_baseline_result must be PASS")
        require(isinstance(layer.get("script_count"), int) and layer.get("script_count") >= 1, f"layer[{idx}].script_count invalid")
        rel_exists(layer.get("action_layer_path"), f"layer[{idx}].action_layer_path")
        rel_exists(layer.get("launcher"), f"layer[{idx}].launcher")
        rel_exists(layer.get("runner"), f"layer[{idx}].runner")
        rel_exists(layer.get("acceptance_record"), f"layer[{idx}].acceptance_record")

if failures:
    print(f"FAIL validate_current_release_pointer failures={len(failures)}")
    for item in failures:
        print(f"- {item}")
    sys.exit(1)

print(f"PASS validate_current_release_pointer release={RELEASE_PATH.relative_to(ROOT)} layers={len(layers)}")
