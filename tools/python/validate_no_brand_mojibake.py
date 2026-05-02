#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]

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

RAW_BRAND = "NOV\u039BK\u2122"

def mojibake_round(value: str) -> str:
    return value.encode("utf-8").decode("cp1252", errors="replace")

patterns = {
    "raw_unicode_brand": RAW_BRAND,
    "raw_unicode_brand_b2": f"{RAW_BRAND} B2",
    "raw_unicode_product": f"{RAW_BRAND} B2 Action Catalog",
}

value = RAW_BRAND
for index in range(1, 6):
    value = mojibake_round(value)
    patterns[f"mojibake_round_{index}_brand"] = value
    patterns[f"mojibake_round_{index}_brand_b2"] = f"{value} B2"
    patterns[f"mojibake_round_{index}_product"] = f"{value} B2 Action Catalog"

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

    for label, pattern in patterns.items():
        if pattern and pattern in text:
            failures.append((str(path.relative_to(ROOT)), label))

if failures:
    print(f"FAIL validate_no_brand_mojibake failures={len(failures)}")
    for rel, label in failures:
        print(f"- {label}: {rel}")
    sys.exit(1)

print("PASS validate_no_brand_mojibake")
