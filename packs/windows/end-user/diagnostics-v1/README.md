# NOenterpriseK B2 Windows End User Easy Button Scripts v1

## Purpose

This pack contains the first **25 end-user-safe, read-only PowerShell scripts** for local testing.

These are intended for baseline review and local acceptance testing before anything is added to an enterprise accepted lane.

## Safety boundary

These scripts are:

- Read-only.
- Current-user context.
- No admin required by design.
- No credentials in code.
- No hardcoded targets.
- No target inventory.
- No production IP lists.
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
launchers\CLICK_ME_Storage_Self_Check_Menu.cmd
```

or:

```text
launchers\CLICK_ME_Run_All_Safe_Local_Checks.cmd
```

## Acceptance model

Use this state path:

```text
CANDIDATE_LOCAL_TEST
  -> TESTED_ON_AUTHOR_MACHINE
  -> ACCEPTED_LOCAL_BASELINE
  -> CANDIDATE_ENTERPRISE_REVIEW
```

Do not call these production-approved until the enterprise review path says so.

## Important wording

You can approve these as your **local baseline scripts** if you are the baseline owner.

Do not describe them as enterprise production approved unless the enterprise process or leadership approval path says so.
