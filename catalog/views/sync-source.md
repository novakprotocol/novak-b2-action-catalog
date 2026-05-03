# NOV&#923;K&trade; B2 Action Catalog - Sync Source

## Current accepted baseline

TEXT-BEGIN
REPO=novakprotocol/novak-b2-action-catalog
BRANCH=main
TESTED_SOURCE_HEAD=cecbf0e
TESTED_SOURCE_FULL_HEAD=cecbf0e1ae57129afd2f0c2b7ba5f6d5f06fd1eb
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
TEXT-END

## How a Windows GUI should consume this

1. Pull or fetch the repository.
2. Read catalog/releases/current-accepted-baseline.json.
3. Only display layers where accepted_for_baseline is true.
4. Do not run mutation actions unless accepted_for_mutation is true.
5. Do not assume workplace approval from this public baseline.

## Safety boundary

This public baseline is generic, no-admin, no-target-list, no-credential, local-user-safe, and read-only by default.

It does not contain workplace IPs, hostnames, usernames, tokens, credentials, or raw evidence.
