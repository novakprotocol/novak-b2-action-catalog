# NOV&#923;K&trade; B2 Action Catalog

Safe-by-default Windows action catalog for end-user self-checks, no-admin diagnostics, and support evidence workflows.

## What this is

This repository is a public, generic action source for:

- Windows end-user self-checks
- no-input diagnostics
- no-admin diagnostics
- safe self-help actions
- dry-run-first self-fix candidates
- manifests and hashes that a GUI or workbench can verify before running actions

The intended downstream consumer is a tool such as **NOV&#923;K&trade; B2 Windows Workbench**.

A workbench can pull this repository as a configured Git Action Source, verify the catalog and script hashes, run accepted actions, and write receipts or evidence into **NOV&#923;K&trade; B2 Object Store**.

## Current accepted baseline

The current accepted public baseline contains:

| Layer | Status | Mutation approved |
|---|---:|---:|
| `everyday-no-admin-v6` | PASS | false |
| `app-self-help-v1` | PASS | false |
| `help-desk-evidence-v1` | PASS | false |

The accepted baseline pointer is here:

- [`catalog/releases/current-accepted-baseline.json`](catalog/releases/current-accepted-baseline.json)
- [`catalog/views/current-accepted-baseline.md`](catalog/views/current-accepted-baseline.md)

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
- internal repository links
- target inventories

This repository does **not** approve production deployment, admin repair, workplace targeting, or automatic remediation.

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

## Catalog views

Browse the catalog:

- [`catalog/views/action-catalog.html`](catalog/views/action-catalog.html)
- [`catalog/views/catalog-by-layer.md`](catalog/views/catalog-by-layer.md)
- [`catalog/views/catalog-by-issue-area.md`](catalog/views/catalog-by-issue-area.md)
- [`catalog/views/catalog-by-action-type.md`](catalog/views/catalog-by-action-type.md)
- [`catalog/views/catalog-by-risk.md`](catalog/views/catalog-by-risk.md)
- [`catalog/views/catalog-by-status.md`](catalog/views/catalog-by-status.md)

Primary machine-readable index:

- [`catalog/generated/action-index.json`](catalog/generated/action-index.json)
- [`catalog/generated/action-index.csv`](catalog/generated/action-index.csv)

## Validation

Run the validators before accepting or publishing changes:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\powershell\Test-AllPowerShellSyntax.ps1
python .\tools\python\validate_action_index.py
python .\tools\python\validate_no_secrets_or_targets.py
python .\tools\python\validate_current_release_pointer.py
python .\tools\python\validate_no_brand_mojibake.py
```

## Work and internal downstream use

Public GitHub should be treated as a generic upstream source.

Internal enterprise repositories should import releases through pull request review, code scanning, no-secrets validation, and local acceptance testing.

Do not blindly auto-run public Git content.

## GitHub Pages

This repository is intended to publish as a static GitHub Pages site from `main:/`.

No Makefile or build system is required right now.

See:

- [`docs/PAGES_DEPLOYMENT.md`](docs/PAGES_DEPLOYMENT.md)
- [`index.html`](index.html)

## Use, attribution, and contributions

Public use, reference, adaptation, or redistribution is allowed only with visible attribution and link-back.

Required attribution:

> Based on NOV&#923;K&trade; B2 Action Catalog by Matthew Novak â€” https://github.com/novakprotocol/novak-b2-action-catalog

Current contribution posture:

| Channel | Status |
|---|---:|
| External contributions | closed |
| Pull requests | closed |
| Issues | closed |
| Discussions | closed |
| Public support channel | closed |

See:

- [`LICENSE.md`](LICENSE.md)
- [`ATTRIBUTION.md`](ATTRIBUTION.md)
- [`NOTICE.md`](NOTICE.md)
- [`CONTRIBUTING.md`](CONTRIBUTING.md)
- [`SECURITY.md`](SECURITY.md)
- [`SUPPORT.md`](SUPPORT.md)
