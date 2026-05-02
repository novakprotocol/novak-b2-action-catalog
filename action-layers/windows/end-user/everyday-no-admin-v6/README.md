# NOVΛK™ B2 Windows Everyday No-Admin Actions v6

This action layer adds 100 more end-user-safe, no-admin, no-input, read-only actions.

## Safety boundary

- Read-only.
- Current-user context.
- No admin required by design.
- No runtime target input.
- No hostnames.
- No IPs.
- No URLs.
- No UNC paths.
- No credentials.
- No mutation.
- Local evidence only.

## Run

Double-click:

`
launchers\CLICK_ME_Run_Everyday_No_Admin_Actions_V6.cmd
`
"@

Write-Utf8 -Path (Join-Path action-layers\windows\end-user\everyday-no-admin-v6\docs "EVERYDAY_NO_ADMIN_V6_SUMMARY.md") -Text @"
# Everyday No-Admin Actions v6

| Range | Category |
|---|---|
| 341-360 | Folder health / old files / extension summaries |
| 361-384 | Environment, commands, processes, service groups |
| 385-400 | Event counts |
| 401-440 | Registry, certificates, devices, tasks, network state |
