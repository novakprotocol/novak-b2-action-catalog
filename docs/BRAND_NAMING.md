# NOV&#923;K&trade; B2 - Brand Naming

## Canonical public display name

TEXT-BEGIN
NOV&#923;K&trade; B2
TEXT-END

## Product line

TEXT-BEGIN
NOV&#923;K&trade; B2 Action Catalog
TEXT-END

## Source encoding rule

Human-facing Markdown and HTML should store the stylized brand as ASCII-safe HTML entities:

TEXT-BEGIN
NOV&#923;K&trade; B2
NOV&#923;K&trade; B2 Action Catalog
TEXT-END

Machine-readable files, scripts, JSON, CSV, schema IDs, repo slugs, paths, action IDs, generated evidence paths, and automation contracts should use ASCII-safe names:

TEXT-BEGIN
NOVAK
NOVAK B2
NOVAK B2 Action Catalog
novak-b2
novak-b2-action-catalog
novak.b2.action.v1
NOVAK-B2-Windows-SelfCheck
TEXT-END

## Current boundary

TEXT-BEGIN
Do not rename repository slug yet.
Do not rename action IDs.
Do not rename schema IDs.
Do not rename script paths.
Do not rename evidence folder paths.
TEXT-END

## Encoding guard

TEXT-BEGIN
Raw stylized Unicode is not stored in source files.
Known brand mojibake is blocked by tools/python/validate_no_brand_mojibake.py.
Do not write raw mojibake strings into documentation.
Machine-safe identifiers remain ASCII.
TEXT-END

Run:

TEXT-BEGIN
python tools/python/validate_no_brand_mojibake.py
TEXT-END
