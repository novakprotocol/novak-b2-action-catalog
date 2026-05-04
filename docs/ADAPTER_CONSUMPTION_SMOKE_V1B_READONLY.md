# Adapter Consumption Smoke v1b â€” Read-Only Default

## What changed

`tools/python/validate_adapter_consumption_smoke_v1.py` now validates the tracked consumption smoke report without rewriting it by default.

## Why

PR #10 proved the consumption smoke validator, but the validator rewrote:

```text
catalog/releases/adapter-consumption-smoke-v1-report.json
```

during normal validation. That made the post-merge worktree dirty even though validation passed.

## New behavior

Default validation is read-only:

```powershell
python .\tools\python\validate_adapter_consumption_smoke_v1.py --expected-actions 5000 --expected-adapters 10
```

Report refresh is explicit:

```powershell
python .\tools\python\validate_adapter_consumption_smoke_v1.py --expected-actions 5000 --expected-adapters 10 --update-report
```

## Boundary

This change does not alter generated adapter outputs, action content, adapter count, action count, or platform integration behavior.
