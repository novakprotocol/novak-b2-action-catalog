function New-FileAccessEvidenceRoot {
    param([string]$ActionId)
    $Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $SafeAction = $ActionId -replace '[^A-Za-z0-9_\-]', '_'
    $Root = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "NOVAK-B2-Windows-SelfCheck"
    $RunRoot = Join-Path $Root "$Stamp-$SafeAction"
    New-Item -ItemType Directory -Force -Path $RunRoot | Out-Null
    return $RunRoot
}

function Write-FileAccessEvidenceResult {
    param([string]$ActionId, [string]$Result, [string]$Message, [hashtable]$Evidence)
    $RunRoot = New-FileAccessEvidenceRoot -ActionId $ActionId
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
            raw_file_contents_collected = $false
            raw_file_paths_collected = $false
            raw_event_text_collected = $false
            credential_collection_allowed = $false
            target_inventory_collection_allowed = $false
        }
        evidence = $Evidence
    }
    $Payload | ConvertTo-Json -Depth 12 | Set-Content -Encoding UTF8 -Path $JsonPath
    @("ACTION_ID=$ActionId", "RESULT=$Result", "MESSAGE=$Message", "EVIDENCE_JSON=$JsonPath", "EVIDENCE_TEXT=$TextPath") | Set-Content -Encoding UTF8 -Path $TextPath
    Write-Host "ACTION_ID=$ActionId"
    Write-Host "RESULT=$Result"
    Write-Host "MESSAGE=$Message"
    Write-Host "EVIDENCE_JSON=$JsonPath"
    Write-Host "EVIDENCE_TEXT=$TextPath"
}

function Get-ServiceStateSafe {
    param([string]$Name)
    $Svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $Svc) { return "not_found" }
    return [string]$Svc.Status
}

function Get-KnownFolderPresenceSafe {
    param([string]$FolderName)
    try {
        $Path = [Environment]::GetFolderPath($FolderName)
        return [ordered]@{ folder=$FolderName; path_value_collected=$false; present=(-not [string]::IsNullOrWhiteSpace([string]$Path) -and (Test-Path $Path)) }
    } catch {
        return [ordered]@{ folder=$FolderName; path_value_collected=$false; present=$false; query_succeeded=$false }
    }
}

function Get-TopLevelFileCountSafe {
    param([string]$FolderName, [string[]]$Extensions)
    try {
        $Path = [Environment]::GetFolderPath($FolderName)
        if ([string]::IsNullOrWhiteSpace([string]$Path) -or -not (Test-Path $Path)) {
            return [ordered]@{ folder=$FolderName; path_value_collected=$false; file_names_collected=$false; count=0; query_succeeded=$true }
        }
        $Files = @(Get-ChildItem -Path $Path -File -ErrorAction SilentlyContinue | Where-Object { $Extensions -contains $_.Extension.ToLowerInvariant() })
        return [ordered]@{ folder=$FolderName; path_value_collected=$false; file_names_collected=$false; count=$Files.Count; query_succeeded=$true }
    } catch {
        return [ordered]@{ folder=$FolderName; path_value_collected=$false; file_names_collected=$false; count=-1; query_succeeded=$false }
    }
}

function Get-AssociationPresenceSafe {
    param([string]$Extension)
    $Result = [ordered]@{ extension=$Extension; registry_value_collected=$false; mutation_performed=$false; association_key_present=$false; association_value_present=$false }
    try {
        $KeyPath = "Registry::HKEY_CLASSES_ROOT\$Extension"
        if (Test-Path $KeyPath) {
            $Result["association_key_present"] = $true
            $Item = Get-ItemProperty -Path $KeyPath -ErrorAction SilentlyContinue
            $Default = $Item.PSObject.Properties | Where-Object { $_.Name -eq "(default)" } | Select-Object -First 1
            $Result["association_value_present"] = $null -ne $Default -and -not [string]::IsNullOrWhiteSpace([string]$Default.Value)
        }
    } catch { $Result["query_succeeded"] = $false }
    return $Result
}

function Get-EventCountSafe {
    param([string]$LogName, [int]$Hours, [int]$Level)
    try {
        $StartTime = (Get-Date).AddHours(-1 * $Hours)
        $Events = Get-WinEvent -FilterHashtable @{ LogName=$LogName; StartTime=$StartTime; Level=$Level } -ErrorAction Stop
        return @($Events).Count
    } catch { return -1 }
}

function Get-RecentShortcutCountSafe {
    try {
        $RecentPath = Join-Path ([Environment]::GetFolderPath("Recent")) "*"
        $Items = @(Get-ChildItem -Path $RecentPath -File -ErrorAction SilentlyContinue)
        return [ordered]@{ recent_item_count=$Items.Count; names_collected=$false; paths_collected=$false; query_succeeded=$true }
    } catch {
        return [ordered]@{ recent_item_count=-1; names_collected=$false; paths_collected=$false; query_succeeded=$false }
    }
}
