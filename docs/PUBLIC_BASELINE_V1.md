# Public Baseline V1

## Status

TEXT-BEGIN
RESULT=PASS
PUBLIC_BASELINE=true
SOURCE_HEAD=bf89ee8
SOURCE_FULL_HEAD=bf89ee89d64ffc9a23ef2c55efbe9bc21885f5fb
RECORDED_UTC=2026-05-03T00:04:11Z
ACCEPTED_LAYER_COUNT=3
ACCEPTED_FOR_MUTATION=false
TEXT-END

## Accepted layers

TEXT-BEGIN
everyday-no-admin-v6=PASS
app-self-help-v1=PASS
help-desk-evidence-v1=PASS
TEXT-END

## What this means

This is the first clean public baseline for the NOV&#923;K&trade; B2 Action Catalog.

It includes safe Windows end-user self-checks, app self-help checks, and local help desk evidence summaries.

## What this does not mean

This baseline does not approve mutation, admin repair, production deployment, workplace targeting, credential collection, raw evidence in Git, or automatic remediation.

## Public entry points

TEXT-BEGIN
README.md
index.html
catalog/views/action-catalog.html
catalog/releases/current-accepted-baseline.json
catalog/views/current-accepted-baseline.md
docs/CURRENT_FLOOR.md
TEXT-END

## Next expansion rule

Expansion must start from this clean floor.

New actions should be added in small scenario packs, validated, locally tested, and accepted only after preserving this baseline.
