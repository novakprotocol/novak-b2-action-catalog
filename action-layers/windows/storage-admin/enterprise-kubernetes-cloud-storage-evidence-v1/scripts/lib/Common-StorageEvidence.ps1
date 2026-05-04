$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0

function Write-SafeActionResult {
    param(
        [Parameter(Mandatory)][int]$Number,
        [Parameter(Mandatory)][string]$ActionId,
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][string]$LayerId,
        [Parameter(Mandatory)][string]$Audience,
        [Parameter(Mandatory)][string]$Tier,
        [Parameter(Mandatory)][string]$IssueArea
    )

    $Result = [ordered]@{
        schema_version = '1.0'
        action_number = $Number
        action_id = $ActionId
        title = $Title
        layer_id = $LayerId
        audience = $Audience
        tier = $Tier
        issue_area = $IssueArea
        status = 'candidate'
        safety_boundary = 'evidence-only-no-remediation-no-mutation-no-secrets-no-target-identifiers'
        mutation_capable = $false
        requires_admin = $true
        stores_credentials = $false
        stores_target_inventory = $false
        evidence_model = 'counts-booleans-generic-status-labels-sanitized-guidance'
        generated_at_utc = (Get-Date).ToUniversalTime().ToString('o')
    }

    $Result | ConvertTo-Json -Depth 8
}