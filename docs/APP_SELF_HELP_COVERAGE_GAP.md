# NOVΛK™ B2 Action Catalog - App Self-Help Coverage Gap

## Status

RESULT=DOCUMENTED

## Current accepted floor

TEXT-BEGIN
HEAD=df8ef87
CATALOG_ACTION_COUNT=440
POWERSHELL_SCRIPT_COUNT=459
VALIDATORS=PASS
TEXT-END

## Current app coverage counts

TEXT-BEGIN
office=11
outlook=3
word=2
excel=2
powerpoint=2
teams=6
onedrive=13
adobe=2
acrobat=2
pdf=4
edge=5
chrome=3
TEXT-END

## Interpretation

The catalog includes Office, Teams, OneDrive, Edge, Chrome, Acrobat, and PDF coverage at a baseline level.

This is not yet complete end-user app self-help coverage.

## Recommended next action layer

TEXT-BEGIN
action-layers/windows/end-user/app-self-help-v1
TEXT-END

## Target scope

TEXT-BEGIN
Office
Outlook
Word
Excel
PowerPoint
Teams
OneDrive
Adobe Acrobat
PDF/default apps
Edge
Chrome
TEXT-END

## Required boundary

TEXT-BEGIN
no-admin
no-credential
no-target-list
local-user-safe
read-only by default
mutation not approved unless explicitly marked safe
TEXT-END

## Known cleanup item

TEXT-BEGIN
Fix text-damaged action id containing AenterpriseILABLE to AVAILABLE.
TEXT-END
