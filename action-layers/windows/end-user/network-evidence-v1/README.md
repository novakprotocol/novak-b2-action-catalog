# network-evidence-v1

network-evidence-v1 is a candidate Action Catalog layer for safe Windows network evidence collection by end users, help desk, and local IT.

## Boundary

- Action Catalog only.
- Windows end-user scope.
- Level 1 / Level 2 boundary, implemented as Level 1 for this candidate.
- No administrator rights required.
- Read-only evidence collection only.
- No remediation.
- No mutation.
- No network scanning.
- No target lists.
- No credentials, tokens, or secrets.
- No workplace identifiers committed.
- No SIS changes.
- No B2 Windows changes.

## Actions

This layer adds action IDs 581-600.

The scripts emit the standard contract:

- ACTION_ID=
- RESULT=PASS, WARN, or FAIL
- MESSAGE=
- EVIDENCE_JSON=
- EVIDENCE_TEXT=

Each script writes sanitized result.json and result.txt under the user's local NOVAK-B2-Windows-SelfCheck output area.

## Sanitization

The layer avoids recording raw usernames, hostnames, domain names, addresses, MAC values, DNS suffixes, SSIDs, VPN names, target server names, printer names, share names, and raw user paths. Evidence uses counts, booleans, generic categories, and read-only guidance.

## Hash policy

Generated catalog metadata uses canonical LF-normalized SHA256 for script hash fields.

## Acceptance status

This candidate sets accepted_for_baseline=false and accepted_for_mutation=false. Baseline acceptance requires validation, local run review, and explicit approval.
## Expansion 601-700

This candidate now includes actions 581-700 for a total of 120 read-only network evidence checks. The expansion keeps accepted_for_baseline=false and accepted_for_mutation=false until explicit review and approval.
