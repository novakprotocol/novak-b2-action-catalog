# App Self-Help V1

## Status

RESULT=CANDIDATE

## Scope

This layer adds 100 safe end-user app self-help actions for Office, Outlook, Word, Excel, PowerPoint, Teams, OneDrive, Adobe Acrobat, PDF/default apps, Edge, Chrome, printers, audio, camera, input, and network settings surfaces.

## Boundary

TEXT-BEGIN
no-admin
no-credential
no-target-list
local-user-safe
read-only by default
mutation not approved by default
TEXT-END

## Runner

TEXT-BEGIN
scripts/checks/000-Run-AppSelfHelp-V1.ps1
TEXT-END
