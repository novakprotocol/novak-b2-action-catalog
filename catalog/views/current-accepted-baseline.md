# Current Accepted Baseline

## Accepted for baseline

TEXT-BEGIN
display_name: NOVAK B2 Action Catalog
tested_source_commit: cecbf0e
accepted_for_baseline: true
accepted_for_mutation: false
layers: everyday-no-admin-v6, app-self-help-v1, help-desk-evidence-v1
catalog_action_count: 560
powershell_script_count: 583
TEXT-END

## Accepted layers

TEXT-BEGIN
everyday-no-admin-v6: PASS baseline accepted, mutation false
app-self-help-v1: PASS baseline accepted, mutation false
help-desk-evidence-v1: PASS baseline accepted, mutation false
TEXT-END

## Meaning

This means the accepted action layers successfully executed on the baseline Windows workstation without admin rights.

It does not mean the actions are approved for enterprise deployment, admin repair, automatic remediation, or mutation.

## Validation evidence

TEXT-BEGIN
PowerShell syntax PASS
catalog actions=560 PASS
no secrets or targets PASS
current release pointer PASS
no brand mojibake PASS
TEXT-END

## Browse all actions

TEXT-BEGIN
catalog/views/action-catalog.html
TEXT-END
