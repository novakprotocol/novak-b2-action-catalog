# Action Index Canonical Hash Policy

## Status

TEXT-BEGIN
RESULT=CANONICALIZED
HASH_POLICY=LF-normalized script content SHA256
REASON=Windows and GitHub Actions may check out text files with different line endings
VALIDATOR=tools/python/validate_action_index.py
RECORDED_UTC=2026-05-03T13:21:03Z
TEXT-END

## Meaning

Action Catalog script hashes are validated against canonical LF-normalized script content.

This avoids false hash mismatches between Windows workstations and Ubuntu GitHub Actions runners.

## Boundary

This is catalog metadata and validator behavior only.

It does not approve mutation.

It does not change SIS.

It does not change B2 Windows.

It does not import raw evidence, raw SIS source pack data, ServiceNow data, credentials, target lists, or endpoint payloads.
