# NOVΛK™ B2 Action Catalog - GitHub Pages Deployment

## Decision

TEXT-BEGIN
GITHUB_PAGES_REQUIRED=true
MAKEFILE_REQUIRED=false
BUILD_SYSTEM_REQUIRED=false
STATIC_SITE=true
PUBLISH_SOURCE=main:/
NOJEKYLL_REQUIRED=true
TEXT-END

## Manual GitHub setting

TEXT-BEGIN
Repo Settings -> Pages
Source: Deploy from a branch
Branch: main
Folder: /root
TEXT-END

## Entry points

TEXT-BEGIN
index.html
catalog/views/action-catalog.html
README.md
TEXT-END

## Boundary

This site is static. Do not add a build system until there is a real reason.

Keep generated catalog files committed and validated before publishing.
