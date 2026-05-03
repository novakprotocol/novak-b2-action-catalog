# NOV&#923;K&trade; B2 Action Catalog - Sync Source

## Current accepted baseline

TEXT-BEGIN
REPO=novakprotocol/novak-b2-action-catalog
BRANCH=work/support-scenario-file-access-v1-from-9c1f002
TESTED_SOURCE_HEAD=4b2ef62
TESTED_SOURCE_FULL_HEAD=4b2ef62d7559d0a93306357e6412d3013fefd693
CURRENT_ACCEPTED_BASELINE=catalog/releases/current-accepted-baseline.json
CATALOG_BROWSER=catalog/views/action-catalog.html
SITE_FRONT_DOOR=index.html
ACCEPTED_FOR_BASELINE=true
ACCEPTED_FOR_MUTATION=false
TEXT-END

## Accepted layers

TEXT-BEGIN
everyday-no-admin-v6
app-self-help-v1
help-desk-evidence-v1
file-access-evidence-v1
TEXT-END

## SIS source

TEXT-BEGIN
SIS_REPO=novakprotocol/novak-b2-support-intelligence-system
SIS_SOURCE_HEAD=7a77285
SIS_TAG=sis-atomic-jsonl-v3-7a77285
SIS_TO_ACTION_CATALOG_REVIEW=PASS
TEXT-END

## How a Windows GUI should consume this

1. Pull or fetch the repository.
2. Read catalog/releases/current-accepted-baseline.json.
3. Only display layers where accepted_for_baseline is true.
4. Do not run mutation actions unless accepted_for_mutation is true.
5. Do not assume workplace approval from this public baseline.

## Safety boundary

This public baseline is generic, no-admin, no-target-list, no-credential, local-user-safe, and read-only by default.

It does not contain workplace IPs, hostnames, usernames, tokens, credentials, raw evidence, raw ServiceNow data, or raw SIS source packs.
