# Network Evidence V1 Candidate

## Candidate layer

- action_layer_id: network-evidence-v1
- Path: action-layers/windows/end-user/network-evidence-v1
- Actions: 581-600
- Status: candidate
- accepted_for_baseline: false
- accepted_for_mutation: false
- Public safe: true
- No admin required: true
- Remediation: false
- Mutation: false

## Implementation summary

This candidate adds 20 read-only Windows PowerShell checks focused on local network evidence. It produces sanitized JSON and text results for help desk handoff and local IT triage.

## Hash policy

Generated action index entries must use canonical LF-normalized SHA256 for script hash fields. The implementation verifies that all new indexed action hash fields match this policy.

## Non-goals

This candidate does not provide remediation, network repair, scanning, target connectivity tests, service restarts, adapter changes, firewall changes, route changes, DNS changes, proxy changes, VPN changes, SIS integration, or B2 Windows runtime integration.

## Validation expectation

Before commit or acceptance, run the PowerShell syntax validator, action index validator, no secrets or targets validator, current release pointer validator, and no brand mojibake validator.
## Expansion update

Actions 601-700 extend the candidate with additional sanitized network evidence categories. The expansion remains no-admin, read-only, no-remediation, no-mutation, no scanning, and no target-list based.
