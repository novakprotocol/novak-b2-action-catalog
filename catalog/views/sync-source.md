# NOVAK B2 Action Catalog - Sync Source

## Current accepted baseline

TEXT-BEGIN
REPO=novakprotocol/novak-b2-action-catalog
BRANCH=main
HEAD=8565cb7
FULL_HEAD=8565cb7a29fc522c03b6a97c915434cec13c5ed9
CURRENT_ACCEPTED_BASELINE=catalog/releases/current-accepted-baseline.json
CATALOG_BROWSER=catalog/views/action-catalog.html
ACCEPTED_FOR_BASELINE=true
ACCEPTED_FOR_MUTATION=false
TEXT-END

## How a Windows GUI should consume this

1. Pull or fetch the repository.
2. Read catalog/releases/current-accepted-baseline.json.
3. Only display layers where accepted_for_baseline is true.
4. Do not run mutation actions unless a future release explicitly sets accepted_for_mutation true.
5. Do not assume workplace approval from this public baseline.

## Safety boundary

This public baseline is generic, no-admin, no-target-list, no-credential, and local-user-safe.

It does not contain workplace IPs, hostnames, usernames, tokens, credentials, or raw evidence.
