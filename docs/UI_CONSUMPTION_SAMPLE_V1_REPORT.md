# UI Consumption Sample v1 Report

## Result

PASS expected after generation and validation.

## Validation command

```powershell
python .\tools\python\generate_ui_consumption_sample_v1.py --sample-size 50 --expected-actions 5000 --expected-adapters 10
python .\tools\python\validate_ui_consumption_sample_v1.py --expected-actions 5000 --expected-adapters 10 --expected-sample-actions 50
```

## Acceptance criteria

- Source action contract JSONL contains 5000 actions.
- UI sample JSON contains 50 browse-only sample actions.
- UI sample HTML contains no external links, scripts, forms, fetch calls, or mutation verbs.
- UI sample preserves the no-execution boundary.
- Full existing Action Catalog validation suite remains PASS.
