# NOenterpriseK B2 Windows End User Next 100 No-Admin Easy Button Scripts v4

## Purpose

This pack adds another 100 end-user-safe checks focused on:

- printers
- Windows profile and File Explorer behavior
- Office / OneDrive / Teams / browser indicators
- network / VPN / Wi-Fi / Bluetooth summaries
- Group Policy / security / update / support readiness

## Safety boundary

These scripts are:

- Read-only.
- Current-user context.
- No admin required by design.
- No runtime target input.
- No hostnames.
- No IPs.
- No URLs.
- No UNC paths.
- No credentials.
- No hardcoded targets.
- No raw target inventory.
- No mutation.
- No remediation.
- Evidence written locally under the current user's Documents folder.

## Easiest way to test

Double-click:

```text
launchers\CLICK_ME_Run_Next_100_No_Admin_Checks_V4.cmd
```

## Evidence location

By default:

```text
%USERPROFILE%\Documents\NOenterpriseK-B2-Windows-SelfCheck
```

## Acceptance model

```text
PASS -> ACCEPTED_LOCAL_BASELINE
WARN -> ACCEPTED_LOCAL_BASELINE_WITH_WARN_BEHAVIOR or TODO_REVIEW
FAIL -> TODO_REVISE_RETEST
```

Warnings are expected where a feature is not installed, a log is unavailable, or a local read-only surface is blocked.
