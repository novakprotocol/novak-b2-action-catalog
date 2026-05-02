# Windows Workbench Integration

Recommended flow:

```text
Git Action Source
  -> action-index.json
  -> verify script paths and SHA256 hashes
  -> display accepted actions
  -> run selected action
  -> capture stdout/stderr/result.json/result.txt
  -> write receipt to NOV&#923;K&trade; B2 Object Store
```

The GUI should not scan random script folders and execute arbitrary files.

It should use:

```text
catalog/generated/action-index.json
```
