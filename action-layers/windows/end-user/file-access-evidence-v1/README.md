# NOV&#923;K&trade; B2 File Access Evidence V1

Candidate action layer for sanitized file access and post-device-replacement support evidence.

## Boundary

TEXT-BEGIN
MUTATION_ALLOWED=false
ADMIN_REQUIRED=false
RAW_FILE_CONTENT_COLLECTION=false
RAW_FILE_PATH_COLLECTION=false
CREDENTIAL_COLLECTION_ALLOWED=false
TARGET_INVENTORY_COLLECTION_ALLOWED=false
TEXT-END

## Runner

TEXT-BEGIN
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\action-layers\windows\end-user\file-access-evidence-v1\scripts\checks\000-Run-FileAccessEvidence-V1.ps1
TEXT-END
