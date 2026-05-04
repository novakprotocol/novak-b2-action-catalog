# Adapter Export Package Index v1

## Purpose

This index gives operators and downstream consumers one stable inventory of the Adapter Export Layer v1 package.

It indexes:

- bounded preview adapter exports
- full 5000-action scaleout adapter exports
- release evidence
- validator/generator tools
- operator documentation

## Boundary

This is an index only.

It does not:

- create live platform integrations
- call Ansible, AWX, AWS, Kubernetes, OpenShift, ServiceNow, or CMDB APIs
- mutate endpoints
- remediate anything
- store credentials
- store secrets
- store raw targets

## Primary file

```text
catalog/releases/adapter-export-package-index-v1.json
```

## Validation

```powershell
python .\tools\python\validate_adapter_export_package_index_v1.py --expected-actions 5000 --expected-adapters 10
```
