# Adapter Export Layer v1 Scaleout - Hard 12 in 8

## Current baseline

- Source index: catalog/generated/action-index.json
- Source action count: $ExpectedActionCount
- Existing PowerShell script count: $ExpectedScriptCount
- Starting main floor: $mainFull

## Mission

Move from bounded preview to consolidated scaleout exports while preserving the evidence-only boundary.

## Hard 12 deliverables

1. Keep main as canonical source floor.
2. Create a dedicated scaleout branch from verified main.
3. Generate consolidated AI contracts for the action catalog.
4. Generate a human runbook index.
5. Generate Ansible vars preview.
6. Generate AWX job-template candidate preview.
7. Generate AWS SSM document candidate preview.
8. Generate Kubernetes evidence action candidate YAML.
9. Generate OpenShift evidence action candidate YAML.
10. Generate ServiceNow import-set candidate preview.
11. Generate CMDB candidate mapping preview.
12. Add a scaleout validator and re-run every existing validator.

## Boundaries

- No mutation.
- No credentials.
- No secrets.
- No raw target lists.
- No network scanning.
- No remediation.
- No service restart.
- No ACL/share/DFS/DNS/firewall/proxy/VPN/storage-array changes.
- No live platform API calls.
- No platform credential references.
- No destructive commands.

## Output model

This scaleout does not create 5000 separate files per platform. It creates consolidated exports that platforms, humans, and AI agents can consume safely.
