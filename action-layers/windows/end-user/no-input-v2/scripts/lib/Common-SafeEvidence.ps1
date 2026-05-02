Set-StrictMode -Version 2.0

function New-ItopsEvidenceContext {
    param(
        [string]$ActionId,
        [string]$EvidenceRoot
    )

    if ([string]::IsNullOrWhiteSpace($EvidenceRoot)) {
        $EvidenceRoot = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "NOenterpriseK-B2-Windows-SelfCheck"
    }

    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $safeAction = ($ActionId -replace '[^A-Za-z0-9_.-]', '_')
    $runDir = Join-Path $EvidenceRoot "$stamp-$safeAction"

    New-Item -ItemType Directory -Path $runDir -Force | Out-Null

    [pscustomobject]@{
        ActionId = $ActionId
        StartedAt = (Get-Date).ToString("o")
        EvidenceRoot = $EvidenceRoot
        RunDir = $runDir
        JsonPath = Join-Path $runDir "result.json"
        TextPath = Join-Path $runDir "result.txt"
    }
}

function Write-ItopsResult {
    param(
        [Parameter(Mandatory=$true)]$Context,
        [Parameter(Mandatory=$true)][string]$Result,
        [string]$Message = "",
        [hashtable]$Data = @{},
        [int]$ExitCode = 0
    )

    $payload = [ordered]@{
        action_id = $Context.ActionId
        result = $Result
        message = $Message
        started_at = $Context.StartedAt
        completed_at = (Get-Date).ToString("o")
        computer_name = $env:COMPUTERNAME
        user_context = "$env:USERDOMAIN\$env:USERNAME"
        evidence_policy = "local_user_profile_only_no_credentials_no_mutation_no_runtime_target_input"
        data = $Data
    }

    $payload | ConvertTo-Json -Depth 8 | Set-Content -Path $Context.JsonPath -Encoding UTF8

    @(
        "ACTION_ID=$($Context.ActionId)"
        "RESULT=$Result"
        "MESSAGE=$Message"
        "COMPUTER=$env:COMPUTERNAME"
        "USER_CONTEXT=$env:USERDOMAIN\$env:USERNAME"
        "JSON=$($Context.JsonPath)"
        "COMPLETED_AT=$((Get-Date).ToString("o"))"
    ) | Set-Content -Path $Context.TextPath -Encoding UTF8

    Write-Host "ACTION_ID=$($Context.ActionId)"
    Write-Host "RESULT=$Result"
    if ($Message) { Write-Host "MESSAGE=$Message" }
    Write-Host "EVIDENCE_JSON=$($Context.JsonPath)"
    Write-Host "EVIDENCE_TEXT=$($Context.TextPath)"

    exit $ExitCode
}

function Invoke-ItopsSafe {
    param(
        [Parameter(Mandatory=$true)][scriptblock]$ScriptBlock,
        [Parameter(Mandatory=$true)]$Context
    )

    try {
        & $ScriptBlock
    }
    catch {
        Write-ItopsResult -Context $Context -Result "WARN" -Message $_.Exception.Message -Data @{
            error_type = $_.Exception.GetType().FullName
            note = "WARN means the local machine blocked or did not support this read-only query."
        } -ExitCode 2
    }
}

function Get-ItopsServiceSummary {
    param([string[]]$Names)

    $out = @()
    foreach ($n in $Names) {
        $svc = Get-Service -Name $n -ErrorAction SilentlyContinue
        if ($svc) {
            $out += @{
                name = $n
                present = $true
                status = [string]$svc.Status
                start_type = try { [string]$svc.StartType } catch { "unknown" }
            }
        } else {
            $out += @{
                name = $n
                present = $false
                status = "not_present"
                start_type = "not_present"
            }
        }
    }
    return $out
}

function Get-ItopsEventCount {
    param(
        [string]$LogName,
        [datetime]$StartTime,
        [string[]]$ProviderNameLike = @(),
        [int[]]$Levels = @(1,2,3)
    )

    try {
        $events = @(Get-WinEvent -FilterHashtable @{ LogName = $LogName; StartTime = $StartTime } -ErrorAction Stop |
            Where-Object {
                $okLevel = $Levels -contains [int]$_.Level
                if ($ProviderNameLike.Count -eq 0) { return $okLevel }
                $prov = [string]$_.ProviderName
                foreach ($p in $ProviderNameLike) {
                    if ($prov -match $p) { return $okLevel }
                }
                return $false
            })
        return $events.Count
    } catch {
        return $null
    }
}
