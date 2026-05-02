# NOVΛK™ B2 Action Catalog - Sync Contract

## Purpose

This document defines the safe sync contract for consumers such as a Windows GUI, a work-controlled mirror, or another local runner.

## Current source file

TEXT-BEGIN
catalog/releases/current-accepted-baseline.json
TEXT-END

## Current local record

TEXT-BEGIN
HEAD=3486469
FULL_HEAD=34864692473d7534b71dc341f1af9c3b212f4df4
RECORDED_LOCAL_TIME=2026-05-02 17:24:29 -04:00
TEXT-END

## Consumer rules

1. Pull or fetch the repository.
2. Read catalog/releases/current-accepted-baseline.json.
3. Only display action layers where accepted_for_baseline is true.
4. Do not run mutation actions unless accepted_for_mutation is true.
5. Confirm all referenced paths exist before showing a button.
6. Treat missing referenced files as a sync failure.
7. Never infer workplace approval from this public baseline.

## Safety boundary

TEXT-BEGIN
no-admin
no-target-list
no-credential
local-user-safe
read-only unless explicitly marked otherwise
mutation not approved
TEXT-END

## Validator

Run:

TEXT-BEGIN
python tools/python/validate_current_release_pointer.py
TEXT-END
