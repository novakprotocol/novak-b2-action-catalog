# NOenterpriseK B2 Windows End User Self-Fix Candidates v5

## Purpose

This pack covers basic Windows areas an end user may be able to correct in their own user context.

It is intentionally different from the earlier diagnostic packs:

- The previous packs mostly observed.
- This pack contains self-fix candidates.

## Critical safety model

Every fix script is **dry-run by default**.

It produces a PLAN unless you run the individual script with:

```powershell
-Apply
```

The run-all launcher is PLAN ONLY and does not apply fixes.

## Safety boundary

- Current-user context.
- No admin required by design.
- No credentials.
- No hardcoded targets.
- No IP lists.
- No server names.
- No permission changes.
- No GPO edits.
- No DFS changes.
- No storage changes.
- No service configuration changes.
- No machine-wide registry changes.
- Local evidence only.

## Example

Dry run:

```powershell
.\scripts\fixes\261-restart-explorer.ps1
```

Apply:

```powershell
.\scripts\fixes\261-restart-explorer.ps1 -Apply
```

## Acceptance model

```text
CANDIDATE_LOCAL_TEST
  -> TESTED_DRY_RUN_ON_AUTHOR_MACHINE
  -> ACCEPTED_LOCAL_BASELINE_DRY_RUN
  -> SELECTIVE_APPLY_TESTED
  -> CANDIDATE_ENTERPRISE_REVIEW
```

Do not bulk-apply these. Test one at a time.
