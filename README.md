# NOVΛK™ B2 Action Catalog

Safe-by-default action catalog and Windows action layers for NOVΛK™ B2.

## What this is

This repository is a public, generic action source for:

- Windows end-user self-checks
- no-input diagnostics
- no-admin diagnostics
- self-fix candidates that are dry-run by default
- manifests and hashes that a GUI/workbench can verify before running actions

The intended consumer is a tool such as:

```text
NOVΛK™ B2 Windows Workbench
```

The Workbench can pull this repository as a configured Git Action Source, verify the catalog and script hashes, run accepted actions, and write receipts/evidence into NOVΛK™ B2 Object Store.

## Safety boundary

This public repository must not contain:

- real IP addresses
- hostnames
- usernames
- passwords
- tokens
- private keys
- employer or agency-specific evidence
- raw logs from real machines
- internal URLs
- internal repo links
- target inventories

## Action model

The action record is the control point. The script is only one implementation.

Each action should declare:

- action ID
- tier
- status
- risk tier
- script path
- script hash
- whether admin is required
- whether runtime input is required
- whether mutation is possible
- whether `-Apply` is required for a change

## Current action layers

```text
action-layers/windows/end-user/diagnostics-v1
action-layers/windows/end-user/no-input-v2
action-layers/windows/end-user/next100-no-input-v3
action-layers/windows/end-user/next100-no-admin-v4
action-layers/windows/end-user/self-fix-candidates-v5
```

## Validate

```bash
tools/run_validators.sh
```

PowerShell syntax check:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\powershell\Test-AllPowerShellSyntax.ps1
```

## Work/internal downstream use

Public GitHub should be treated as a generic upstream source.

Internal enterprise repositories should import releases through pull request review, code scanning, no-secrets validation, and local acceptance testing.

Do not blindly auto-run public Git content.

## Catalog views

View the generated catalog by:

catalog/views/action-catalog.html
catalog/views/catalog-by-layer.md
catalog/views/catalog-by-issue-area.md
catalog/views/catalog-by-action-type.md
catalog/views/catalog-by-risk.md
catalog/views/catalog-by-status.md

Primary machine-readable index:

catalog/generated/action-index.json
