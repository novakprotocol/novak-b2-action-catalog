# Adapter Consumption Smoke v1

Parser and boundary smoke test for downstream platform consumption.

This proves the accepted adapter export floor can be consumed as files without live execution.

## Boundary

- No live AWS/AWX/Kubernetes/OpenShift/ServiceNow/CMDB API calls
- No mutation
- No remediation
- No credentials
- No secrets
- No raw targets
- Plain-English action text like reboot guidance is allowed; command-shaped reboot execution is not.
- Platform YAML/text projections are checked as safe non-empty projections.
- The exact 5000-action count is proven by the canonical AI JSONL action-contract stream.
- GitOps kustomization preview may use configMapGenerator instead of resources.

## Required PASS

``text
PASS validate_adapter_consumption_smoke_v1 files=13 actions=5000 adapters=10
``
