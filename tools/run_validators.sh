#!/usr/bin/env bash
set -Eeuo pipefail
set +H
python3 tools/python/validate_action_index.py
python3 tools/python/validate_no_secrets_or_targets.py
echo "PASS all Python validators"
echo "PowerShell syntax validator is available at tools/powershell/Test-AllPowerShellSyntax.ps1"
