function New-HelpDeskEvidenceRoot {
    param([string]$ActionId)

    $Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $SafeAction = $ActionId -replace '[^A-Za-z0-9_\-]', '_'
    $Root = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "NOVAK-B2-Windows-SelfCheck"
    $RunRoot = Join-Path $Root "$Stamp-$SafeAction"

    New-Item -ItemType Directory -Force -Path $RunRoot | Out-Null
    return $RunRoot
}

function Write-HelpDeskEvidenceResult {
    param(
        [string]$ActionId,
        [string]$Result,
        [string]$Message,
        [hashtable]$Evidence
    )

    $RunRoot = New-HelpDeskEvidenceRoot -ActionId $ActionId
    $JsonPath = Join-Path $RunRoot "result.json"
    $TextPath = Join-Path $RunRoot "result.txt"

    $Payload = [ordered]@{
        action_id = $ActionId
        result = $Result
        message = $Message
        collected_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        safety_boundary = [ordered]@{
            no_admin_required = $true
            mutation_performed = $false
            raw_event_text_collected = $false
            raw_file_paths_collected = $false
            credential_collection_allowed = $false
            target_inventory_collection_allowed = $false
        }
        evidence = $Evidence
    }

    $Payload | ConvertTo-Json -Depth 12 | Set-Content -Encoding UTF8 -Path $JsonPath

    @(
        "ACTION_ID=$ActionId",
        "RESULT=$Result",
        "MESSAGE=$Message",
        "EVIDENCE_JSON=$JsonPath",
        "EVIDENCE_TEXT=$TextPath"
    ) | Set-Content -Encoding UTF8 -Path $TextPath

    Write-Host "ACTION_ID=$ActionId"
    Write-Host "RESULT=$Result"
    Write-Host "MESSAGE=$Message"
    Write-Host "EVIDENCE_JSON=$JsonPath"
    Write-Host "EVIDENCE_TEXT=$TextPath"
}

function Get-ServiceStateSafe {
    param([string]$Name)

    $Svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $Svc) {
        return "not_found"
    }

    return [string]$Svc.Status
}

function Get-ProcessCountSafe {
    param([string[]]$Names)

    $Result = [ordered]@{}
    foreach ($Name in $Names) {
        $Result[$Name] = @(Get-Process -Name $Name -ErrorAction SilentlyContinue).Count
    }
    return $Result
}

function Get-EventCountSafe {
    param(
        [string]$LogName,
        [int]$Hours,
        [int]$Level
    )

    $StartTime = (Get-Date).AddHours(-1 * $Hours)

    try {
        $Events = Get-WinEvent -FilterHashtable @{
            LogName = $LogName
            StartTime = $StartTime
            Level = $Level
        } -ErrorAction Stop

        return @($Events).Count
    }
    catch {
        return -1
    }
}
