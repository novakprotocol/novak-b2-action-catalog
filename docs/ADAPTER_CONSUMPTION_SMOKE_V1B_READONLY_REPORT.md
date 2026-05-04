# Adapter Consumption Smoke v1b Validation Report

## Result

Expected result after this change:

```text
PASS validate_adapter_consumption_smoke_v1 files=13 actions=5000 adapters=10 report_mode=checked_read_only
WORKTREE_CLEAN=true
```

## Proven behavior

- The 5000-action AI JSONL contract remains the canonical all-action proof.
- Text projections are still treated as safe projections.
- Plain-English action text such as `Reboot` is allowed.
- Command-shaped mutation/live operations remain blocked.
- The tracked report is checked semantically, not rewritten during normal validation.

## Update path

Only use `--update-report` when the generated adapter release files intentionally change.
