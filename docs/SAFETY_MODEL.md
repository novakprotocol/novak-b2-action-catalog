# Safety Model

## Core rule

No manifest = do not run.

No hash match = do not run.

No accepted status = do not run outside developer/test mode.

Mutation-capable actions must be disabled by default and require explicit `-Apply`.

## Public upstream / internal downstream

Public repository:

```text
generic scripts and manifests only
```

Internal downstream:

```text
reviewed accepted copy with internal policy
```
