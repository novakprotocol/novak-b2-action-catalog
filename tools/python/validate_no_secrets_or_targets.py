#!/usr/bin/env python3
import pathlib, re, sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
SKIP_DIRS = {".git", ".github"}
PATTERNS = [
    re.compile(r"(?i)\bpassword\s*="),
    re.compile(r"(?i)\bpasswd\s*="),
    re.compile(r"(?i)\btoken\s*="),
    re.compile(r"(?i)\bapi[_-]?key\s*="),
    re.compile(r"BEGIN RSA PRIVATE KEY"),
    re.compile(r"BEGIN OPENSSH PRIVATE KEY"),
    re.compile(r"(?<![A-Za-z0-9])(?:10|127|169\.254|192\.168|172\.(?:1[6-9]|2[0-9]|3[0-1]))(?:\.\d{1,3}){3}(?![A-Za-z0-9])"),
]
TEXT_EXTS = {".ps1",".cmd",".md",".json",".csv",".txt",".yml",".yaml",".psm1",".psd1"}

checked = 0
for path in ROOT.rglob("*"):
    if not path.is_file():
        continue
    if any(part in SKIP_DIRS for part in path.parts):
        continue
    if path.suffix.lower() not in TEXT_EXTS:
        continue
    text = path.read_text(encoding="utf-8", errors="ignore")
    rel = path.relative_to(ROOT)
    for pat in PATTERNS:
        if pat.search(text):
            print(f"FAIL possible secret/target pattern {pat.pattern} in {rel}", file=sys.stderr)
            sys.exit(1)
    checked += 1

print(f"PASS validate_no_secrets_or_targets files_checked={checked}")
