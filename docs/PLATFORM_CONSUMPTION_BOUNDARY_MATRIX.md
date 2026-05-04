# Platform Consumption Boundary Matrix

| Projection | Consumer | Allowed now | Not allowed now |
|---|---|---|---|
| AI contract JSONL | AI agent / assistant | Explain, select, compare, route evidence actions | Execute, approve mutation, infer credentials |
| Human runbook index | Human operator | Read, triage, escalate, link to evidence actions | Hide remediation inside evidence steps |
| Ansible vars | Ansible / AWX input data | Represent evidence-only action metadata | Run destructive playbooks or modify systems |
| AWX candidates | AWX job-template preview | Candidate metadata for later controlled templates | Live job execution, credentials, mutation |
| AWS SSM candidates | AWS SSM document preview | Evidence-only document candidate shape | Patch, restart, delete, attach, detach, permission changes |
| Kubernetes jobs | Kubernetes preview | Evidence collection job candidate shape | Cluster mutation, privileged repair, secret mounts |
| OpenShift jobs | OpenShift preview | Evidence collection job candidate shape | Cluster mutation, privileged repair, secret mounts |
| ServiceNow import set | ServiceNow metadata import preview | Catalog metadata for ticket/routing context | Auto-close, auto-assign, auto-prioritize, approval creation |
| CMDB mapping | CMDB evidence mapping preview | Candidate CI evidence mapping | Assert authoritative ownership or environment without verification |
| GitOps kustomization | GitOps layout preview | Declare generated preview files as reviewed artifacts | Apply live cluster/platform changes |
