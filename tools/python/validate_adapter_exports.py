#!/usr/bin/env python3
from __future__ import annotations
import json, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / 'catalog/generated/adapters'
MANIFEST = BASE / 'adapter-manifest.json'
FORBIDDEN = [
    'mutation_allowed: true','"mutation_allowed": true',
    'accepted_for_mutation: true','"accepted_for_mutation": true',
    'remove-item','restart-service','stop-service','set-acl',
    'new-smbshare','remove-smbshare','format-volume','clear-disk',
    'invoke-restmethod','invoke-webrequest','connect-viserver'
]
def fail(msg: str) -> None:
    print(f'FAIL validate_adapter_exports {msg}')
    sys.exit(1)
if not MANIFEST.exists():
    fail('missing adapter-manifest.json')
manifest = json.loads(MANIFEST.read_text(encoding='utf-8'))
if manifest.get('schema_version') != 'adapter-manifest.v1':
    fail('bad manifest schema_version')
if manifest.get('bounded_preview') is not True:
    fail('bounded_preview is not true')
sample_count = int(manifest.get('sample_count', 0))
if sample_count < 1 or sample_count > 25:
    fail('sample_count not bounded 1..25')
boundary = manifest.get('boundary', {})
for key in ['mutation_allowed','live_platform_calls_allowed','secrets_allowed','raw_target_lists_allowed','network_scan_allowed']:
    if boundary.get(key) is not False:
        fail(f'bad boundary {key}')
for rel in manifest.get('adapters', []):
    p = BASE / rel
    if not p.exists():
        fail(f'missing adapter {rel}')
    text = p.read_text(encoding='utf-8', errors='ignore').lower()
    for token in FORBIDDEN:
        if token in text:
            fail(f'forbidden token {token} in {rel}')
ai_path = BASE / 'ai/action-contract.sample.json'
if not ai_path.exists():
    fail('missing ai/action-contract.sample.json')
ai = json.loads(ai_path.read_text(encoding='utf-8'))
actions = ai.get('actions', [])
if len(actions) != sample_count:
    fail('sample_count mismatch')
ids_a = {x.get('action_id') for x in actions}
ids_m = {x.get('action_id') for x in manifest.get('sample_actions', [])}
if ids_a != ids_m:
    fail('manifest action ids do not match contract sample')
for a in actions:
    if a.get('mutation_allowed') is not False:
        fail(f"mutation leak {a.get('action_id')}")
    if a.get('accepted_for_mutation') is not False:
        fail(f"accepted_for_mutation leak {a.get('action_id')}")
    if a.get('secret_policy') != 'no_secrets' or a.get('target_policy') != 'no_targets':
        fail(f"boundary leak {a.get('action_id')}")
print(f"PASS validate_adapter_exports adapters={len(manifest.get('adapters', []))} exported_actions={len(actions)}")
