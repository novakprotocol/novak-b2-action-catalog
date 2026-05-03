#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')
. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1-Expansion.ps1')

Invoke-NetworkEvidenceExpansionAction -ActionId 'ENDUSER_NETWORK_WINHTTP_PROXY_PRESENCE_SUMMARY_V1' -Slug 'network-winhttp-proxy-presence-summary' -Profile 'proxy' -Title 'Network WinHTTP proxy presence summary'