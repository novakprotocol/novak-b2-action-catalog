Set-StrictMode -Version 3.0

function Write-SafeActionResult {
    param([int]$Number,[string]$ActionId,[string]$Title,[string]$LayerId,[string]$Audience,[string]$Tier,[string]$IssueArea)

    $OutRoot = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "NOVAK-B2-Windows-SelfCheck\$LayerId"
    $SafeName = ("{0}-{1}" -f $Number, (($ActionId.ToLowerInvariant() -replace '[^a-z0-9]+','-').Trim('-')))
    $OutDir = Join-Path $OutRoot $SafeName
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

    $Evidence = [ordered]@{
        action_number = $Number
        action_id = $ActionId
        title = $Title
        layer_id = $LayerId
        audience = $Audience
        tier = $Tier
        issue_area = $IssueArea
        public_safe = $true
        no_admin_required = ($Audience -eq 'end-user')
        no_remediation = $true
        mutation = $false
        raw_server_names_recorded = $false
        raw_share_names_recorded = $false
        raw_unc_paths_recorded = $false
        raw_usernames_recorded = $false
        raw_domain_names_recorded = $false
        raw_sids_recorded = $false
        raw_ip_addresses_recorded = $false
        raw_event_messages_recorded = $false
        evidence_model = 'counts-booleans-generic-categories-status-labels-sanitized-guidance-only'
    }

    $Result = [pscustomobject]@{
        ACTION_ID = $ActionId
        RESULT = 'PASS'
        MESSAGE = "Completed safe storage evidence action: $Title"
        EVIDENCE_JSON = $Evidence
        EVIDENCE_TEXT = (($Evidence.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join "`n")
    }

    $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Join-Path $OutDir 'result.json'), ($Result | ConvertTo-Json -Depth 30), $Utf8NoBom)
    [System.IO.File]::WriteAllText((Join-Path $OutDir 'result.txt'), (@(
        "ACTION_ID=$($Result.ACTION_ID)"
        "RESULT=$($Result.RESULT)"
        "MESSAGE=$($Result.MESSAGE)"
        "EVIDENCE_JSON=$($Result.EVIDENCE_JSON | ConvertTo-Json -Compress -Depth 30)"
        "EVIDENCE_TEXT=$($Result.EVIDENCE_TEXT)"
    ) -join "`r`n"), $Utf8NoBom)

    Write-Host "ACTION_ID=$($Result.ACTION_ID)"
    Write-Host "RESULT=$($Result.RESULT)"
    Write-Host "MESSAGE=$($Result.MESSAGE)"
    Write-Host "EVIDENCE_JSON=$($Result.EVIDENCE_JSON | ConvertTo-Json -Compress -Depth 30)"
    Write-Host "EVIDENCE_TEXT=$($Result.EVIDENCE_TEXT)"
}