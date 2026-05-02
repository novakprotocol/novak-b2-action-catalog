# NOenterpriseK B2 Windows End User No-Input Easy Button Scripts v2

## Purpose

This pack adds more end-user-safe checks that require **no target name, no IP, no URL, and no runtime input**.

It is intended for local baseline testing after v1.

## Safety boundary

These scripts are:

- Read-only.
- Current-user context.
- No admin required by design.
- No runtime target input.
- No credentials.
- No hardcoded targets.
- No production IP lists.
- No raw target inventory.
- No mutation.
- No remediation.
- Evidence written locally under the current user's Documents folder.

## Evidence location

By default:

```text
%USERPROFILE%\Documents\NOenterpriseK-B2-Windows-SelfCheck
```

## Easiest way to test

Double-click:

```text
launchers\CLICK_ME_Run_All_No_Input_Checks_V2.cmd
```

## Acceptance model

Use this state path:

```text
CANDIDATE_LOCAL_TEST
  -> TESTED_ON_AUTHOR_MACHINE
  -> ACCEPTED_LOCAL_BASELINE
  -> CANDIDATE_ENTERPRISE_REVIEW
```

## Notes

Some scripts may return WARN if a Windows feature is absent or access to a read-only query is blocked. WARN is not automatically unsafe; it means the result needs review.
