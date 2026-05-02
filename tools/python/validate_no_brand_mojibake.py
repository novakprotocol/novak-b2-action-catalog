#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]

BAD_PATTERNS = {
    "bad_lambda_tm": "NOV\u00CE\u203AK\u00E2\u201E\u00A2",
    "bad_lambda_tm_b2": "NOV\u00CE\u203AK\u00E2\u201E\u00A2 B2",
    "bad_lambda_only": "NOV\u00CE\u203AK",
}

TEXT_EXTENSIONS = {
    ".md",
    ".html",
    ".json",
    ".csv",
    ".yml",
    ".yaml",
    ".txt",
    ".ps1",
    ".cmd",
}

SKIP_PARTS = {
    ".git",
}

failures = []

for path in ROOT.rglob("*"):
    if not path.is_file():
        continue
    if path.suffix.lower() not in TEXT_EXTENSIONS:
        continue
    if any(part in SKIP_PARTS for part in path.parts):
        continue

    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        continue

    for label, pattern in BAD_PATTERNS.items():
        if pattern in text:
            failures.append((str(path.relative_to(ROOT)), label))

if failures:
    print(f"FAIL validate_no_brand_mojibake failures={len(failures)}")
    for rel, label in failures:
        print(f"- {label}: {rel}")
    sys.exit(1)

print("PASS validate_no_brand_mojibake")
