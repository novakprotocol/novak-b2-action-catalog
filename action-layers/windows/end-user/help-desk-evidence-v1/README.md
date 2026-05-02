# NOV&#923;K&trade; B2 Help Desk Evidence V1

Candidate action layer for sanitized, local, ticket-ready help desk evidence packaging.

## Boundary

```text
MUTATION_ALLOWED=false
ADMIN_REQUIRED=false
RAW_EVENT_TEXT_COLLECTED=false
RAW_FILE_PATHS_COLLECTED=false
CREDENTIAL_COLLECTION_ALLOWED=false
TARGET_INVENTORY_COLLECTION_ALLOWED=false
```

## Runner

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\action-layers\windows\end-user\help-desk-evidence-v1\scripts\checks\000-Run-HelpDeskEvidence-V1.ps1
```

