# Script Catalog Audit V1

## Status

```text
RESULT=PASS_WITH_REVIEW_ITEMS
RECORDED_UTC=2026-05-02T23:51:43Z
ACTION_INDEX_SOURCE=$.actions
ACTION_COUNT=560
POWERSHELL_SCRIPT_COUNT=583
MISSING_SCRIPT_REF_COUNT=0
EMPTY_SCRIPT_REF_COUNT=0
DUPLICATE_ACTION_ID_COUNT=0
RISK_PATTERN_HIT_COUNT=21
```

## Action counts by layer

| Layer | Count |
|---|---|
| action-layers/windows/end-user/app-self-help-v1 | 100 |
| action-layers/windows/end-user/diagnostics-v1 | 25 |
| action-layers/windows/end-user/everyday-no-admin-v6 | 100 |
| action-layers/windows/end-user/help-desk-evidence-v1 | 20 |
| action-layers/windows/end-user/next100-no-admin-v4 | 100 |
| action-layers/windows/end-user/next100-no-input-v3 | 100 |
| action-layers/windows/end-user/no-input-v2 | 35 |
| action-layers/windows/end-user/self-fix-candidates-v5 | 80 |

## Action counts by risk

| Risk | Count |
|---|---|
| LOW_READONLY | 360 |
| LOW_USER_SCOPE_SELF_FIX | 80 |
| low | 120 |

## Action counts by status

| Status | Count |
|---|---|
| CANDIDATE_LOCAL_TEST | 440 |
| candidate | 120 |

## PowerShell script classification

| Class | Count |
|---|---|
| cataloged | 560 |
| library | 8 |
| root_operator | 3 |
| runner | 6 |
| tool | 1 |
| unindexed | 5 |

## Missing or empty script references

```text
MISSING_OR_EMPTY_SCRIPT_REFERENCES=0
```

## Duplicate action IDs

```text
DUPLICATE_ACTION_IDS=0
```

## Unindexed scripts

These are PowerShell scripts that are not referenced by the action index and are not classified as tools, runners, libraries, or root operator scripts.

```text
UNINDEXED_SCRIPT_COUNT=5
```
- `action-layers/windows/end-user/diagnostics-v1/acceptance/Test-PackSyntax.ps1`
- `action-layers/windows/end-user/next100-no-admin-v4/acceptance/Test-PackSyntax.ps1`
- `action-layers/windows/end-user/next100-no-input-v3/acceptance/Test-PackSyntax.ps1`
- `action-layers/windows/end-user/no-input-v2/acceptance/Test-PackSyntax.ps1`
- `action-layers/windows/end-user/self-fix-candidates-v5/acceptance/Test-PackSyntax.ps1`

## Risk-pattern review hits

These are string-pattern hits only. They are review items, not automatic proof of unsafe behavior.

```text
RISK_PATTERN_HIT_COUNT=21
```
- `Repair-NOVAK-B2-ActionCatalog-V6Existing-v2.ps1:98` pattern=`Remove-Item` text=`Remove-Item -LiteralPath $_.FullName -Force`
- `Repair-NOVAK-B2-ActionCatalog-V6Existing.ps1:98` pattern=`Remove-Item` text=`Remove-Item -LiteralPath $_.FullName -Force`
- `action-layers/windows/end-user/diagnostics-v1/scripts/checks/07-Test-UrlStatus.ps1:25` pattern=`Invoke-WebRequest` text=`$resp = Invoke-WebRequest -Uri $TargetUrl -Method Head -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:22` pattern=`Clear-` text=`"268-clear-clipboard.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:40` pattern=`Clear-` text=`"286-clear-user-temp-older-7-days.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:41` pattern=`Clear-` text=`"287-clear-user-temp-all.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:42` pattern=`Clear-` text=`"288-clear-internet-cache.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:43` pattern=`Clear-` text=`"289-clear-temp-internet-files.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:44` pattern=`Clear-` text=`"290-clear-edge-cache.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:45` pattern=`Clear-` text=`"291-clear-chrome-cache.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:46` pattern=`Clear-` text=`"292-clear-teams-classic-cache.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:47` pattern=`Clear-` text=`"293-clear-teams-new-cache.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:48` pattern=`Clear-` text=`"294-clear-office-file-cache.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:49` pattern=`Clear-` text=`"295-clear-onedrive-logs-older-14-days.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:50` pattern=`Clear-` text=`"296-clear-explorer-thumb-cache.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:51` pattern=`Clear-` text=`"297-clear-crash-dumps-older-14-days.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:52` pattern=`Clear-` text=`"298-clear-wer-archive-older-14-days.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:53` pattern=`Clear-` text=`"299-clear-wer-queue-older-14-days.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/fixes/000-Run-AllSelfFixCandidates-V5-PLAN-ONLY.ps1:54` pattern=`Clear-` text=`"300-clear-recent-items.ps1";`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/lib/Common-SelfFixV5.ps1:131` pattern=`Remove-Item` text=`Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop`
- `action-layers/windows/end-user/self-fix-candidates-v5/scripts/lib/Common-SelfFixV5.ps1:216` pattern=`Clear-` text=`Clear-RecycleBin -Force -ErrorAction Stop`

## Interpretation

- `cataloged` scripts are referenced by the generated action index.
- `runner` scripts are layer launchers and should not necessarily appear as normal actions.
- `tool` scripts are repository maintenance tools.
- `library` scripts support other scripts.
- `root_operator` scripts are repo-construction or repair helpers and should not be treated as end-user actions.
- `unindexed` scripts require review before expansion.

## Next recommended work

1. Review any unindexed scripts.
2. Review risk-pattern hits and confirm whether each is plan-only, read-only, or intentionally operator-only.
3. After this audit floor is accepted, add `help-desk-evidence-v1` as the next action layer.

