# UI Consumption Sample v1

This is a static, browse-only Action Catalog UI consumption sample.

## Purpose

Prove that a human or machine-facing UI can consume the Adapter Export Layer v1 package without invoking a live platform, storing credentials, calling external services, or granting mutation authority.

## Files

- `catalog/generated/ui-consumption-sample-v1/actions.sample.json`
- `catalog/generated/ui-consumption-sample-v1/index.html`
- `catalog/releases/ui-consumption-sample-v1-report.json`
- `tools/python/generate_ui_consumption_sample_v1.py`
- `tools/python/validate_ui_consumption_sample_v1.py`

## Boundaries

- Browse-only sample.
- No execution.
- No credentials.
- No network calls.
- No live platform API calls.
- No remediation.
- No generated adapter package mutation.
