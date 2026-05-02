#!/usr/bin/env python3
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path.cwd()

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

HUMAN_EXTENSIONS = {
    ".md",
    ".html",
}

SKIP_PARTS = {
    ".git",
}

RAW_BRAND = "NOV\u039BK\u2122"
RAW_B2 = f"{RAW_BRAND} B2"
RAW_PRODUCT = f"{RAW_BRAND} B2 Action Catalog"

ENTITY_BRAND = "NOV&#923;K&trade;"
ENTITY_B2 = "NOV&#923;K&trade; B2"
ENTITY_PRODUCT = "NOV&#923;K&trade; B2 Action Catalog"

ASCII_BRAND = "NOVAK"
ASCII_B2 = "NOVAK B2"
ASCII_PRODUCT = "NOVAK B2 Action Catalog"


def mojibake_round(value: str) -> str:
    return value.encode("utf-8").decode("cp1252", errors="replace")


def target_values(path: Path):
    if path.suffix.lower() in HUMAN_EXTENSIONS:
        return ENTITY_BRAND, ENTITY_B2, ENTITY_PRODUCT
    return ASCII_BRAND, ASCII_B2, ASCII_PRODUCT


def build_bad_variants():
    variants = set()

    value = RAW_BRAND
    for _ in range(0, 10):
        variants.add(value)
        variants.add(f"{value} B2")
        variants.add(f"{value} B2 Action Catalog")
        value = mojibake_round(value)

    # Also catch the already-normalized-but-wrong blocked placeholder from earlier attempt.
    variants.add("[blocked-brand-mojibake]")
    variants.add("[blocked-brand-mojibake] B2")
    variants.add("[blocked-brand-mojibake] B2 Action Catalog")

    return sorted(variants, key=len, reverse=True)


BAD_VARIANTS = build_bad_variants()


def repair_text(path: Path, text: str) -> str:
    brand_repl, b2_repl, product_repl = target_values(path)

    new = text

    for bad in BAD_VARIANTS:
        if not bad:
            continue

        if bad.endswith(" B2 Action Catalog"):
            repl = product_repl
        elif bad.endswith(" B2"):
            repl = b2_repl
        else:
            repl = brand_repl

        new = new.replace(bad, repl)

    # Regex fallback for unknown multi-mojibake forms.
    # Match NOV + non-ASCII junk + K + optional junk + known suffix.
    product_pattern = re.compile(r"NOV[^A-Za-z0-9\r\n]{1,240}K[^\r\n]{0,240}? B2 Action Catalog")
    b2_pattern = re.compile(r"NOV[^A-Za-z0-9\r\n]{1,240}K[^\r\n]{0,240}? B2")
    brand_pattern = re.compile(r"NOV[^A-Za-z0-9\r\n]{1,240}K[^\s,<\]\)\r\n]{0,240}")

    new = product_pattern.sub(product_repl, new)
    new = b2_pattern.sub(b2_repl, new)
    new = brand_pattern.sub(brand_repl, new)

    # Cleanup accidental duplicated B2/Product forms.
    new = new.replace("NOVAK B2 B2 Action Catalog", ASCII_PRODUCT)
    new = new.replace("NOVAK B2 B2", ASCII_B2)
    new = new.replace("NOV&#923;K&trade; B2 B2 Action Catalog", ENTITY_PRODUCT)
    new = new.replace("NOV&#923;K&trade; B2 B2", ENTITY_B2)

    return new


changed = []

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

    repaired = repair_text(path, text)

    if repaired != text:
        path.write_text(repaired, encoding="utf-8", newline="")
        changed.append(str(path.relative_to(ROOT)))

for rel in changed:
    print(f"REPAIRED={rel}")

print(f"BRAND_FILES_REPAIRED={len(changed)}")
