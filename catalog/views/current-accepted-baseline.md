# Current Accepted Baseline

## Accepted for baseline

TEXT-BEGIN
display_name: NOVΛK™ B2 Action Catalog
source_commit: 0bb5e0a
accepted_for_baseline: true
accepted_for_mutation: false
layers: everyday-no-admin-v6, app-self-help-v1
TEXT-END

## Accepted layers

TEXT-BEGIN
everyday-no-admin-v6: PASS baseline accepted, mutation false
app-self-help-v1: PASS baseline accepted, mutation false
TEXT-END

## Meaning

This means the accepted action layers successfully executed on the baseline Windows workstation without admin rights.

It does not mean the actions are approved for enterprise deployment, admin repair, automatic remediation, or mutation.

## Validation evidence

TEXT-BEGIN
PowerShell syntax scripts=561 PASS
catalog actions=540 PASS
no secrets or targets files_checked=623 PASS
current release pointer PASS
TEXT-END

## Browse all actions

TEXT-BEGIN
catalog/views/action-catalog.html
TEXT-END
