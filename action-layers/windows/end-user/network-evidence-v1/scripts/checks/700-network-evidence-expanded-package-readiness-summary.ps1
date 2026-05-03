#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_EVIDENCE_EXPANDED_PACKAGE_READINESS_SUMMARY_V1' -Slug 'network-evidence-expanded-package-readiness-summary' -Profile 'readiness' -Title 'Network evidence expanded package readiness summary'