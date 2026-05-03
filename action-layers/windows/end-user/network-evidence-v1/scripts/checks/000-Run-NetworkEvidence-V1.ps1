#requires -Version 5.1
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\Common-NetworkEvidenceV1.ps1')

$ActionId = 'ENDUSER_NETWORK_EVIDENCE_RUNNER_V1'
$ExpectedCheckCount = 120

try {
    $checks = @(Get-ChildItem -Path $PSScriptRoot -Filter '*.ps1' -File |
        Where-Object { $_.Name -match '^[0-9]{3}-.*\.ps1$' -and $_.Name -notmatch '^000-' } |
        Sort-Object Name)

    if ($checks.Count -ne $ExpectedCheckCount) {
        $evidence = [ordered]@{
            collection_completed = $false
            check_count = $checks.Count
            expected_check_count = $ExpectedCheckCount
            read_only = $true
            no_admin_required = $true
            remediation_performed = $false
            mutation_performed = $false
        }

        Write-NetworkEvidenceResult -ActionId $ActionId -Result 'FAIL' -Message 'Network evidence runner did not discover the expected checks.' -Evidence $evidence -EvidenceText 'Network evidence runner did not discover the expected checks.'
        exit 1
    }

    $passCount = 0
    $warnCount = 0
    $failCount = 0
    $observedActionIds = New-Object System.Collections.Generic.List[string]

    foreach ($check in $checks) {
        Write-Host ("Running {0}" -f $check.Name)

        $oldPreference = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'Continue'
            $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $check.FullName 2>&1
            $exitCode = $LASTEXITCODE
        }
        finally {
            $ErrorActionPreference = $oldPreference
        }

        $actionLine = ($output | Where-Object { [string]$_ -match '^ACTION_ID=' } | Select-Object -Last 1)
        $resultLine = ($output | Where-Object { [string]$_ -match '^RESULT=' } | Select-Object -Last 1)
        $messageLine = ($output | Where-Object { [string]$_ -match '^MESSAGE=' } | Select-Object -Last 1)

        if ($actionLine) {
            $observedActionIds.Add(([string]$actionLine).Substring(10))
            Write-Host ("  {0}" -f $actionLine)
        }

        if ($resultLine) {
            Write-Host ("  {0}" -f $resultLine)
        }

        if ($messageLine) {
            Write-Host ("  {0}" -f $messageLine)
        }

        $result = if ($resultLine) { ([string]$resultLine).Substring(7) } else { 'FAIL' }

        switch ($result) {
            'PASS' { $passCount++ }
            'WARN' { $warnCount++ }
            default { $failCount++ }
        }

        if ($exitCode -ne 0 -and $result -ne 'FAIL') {
            $failCount++
        }
    }

    $resultValue = if ($failCount -gt 0) { 'FAIL' } elseif ($warnCount -gt 0) { 'WARN' } else { 'PASS' }
    $message = if ($failCount -gt 0) {
        'Network evidence runner completed with one or more failed checks.'
    }
    elseif ($warnCount -gt 0) {
        'Network evidence runner completed with warnings; review sanitized evidence.'
    }
    else {
        'Network evidence runner completed successfully.'
    }

    $evidence = [ordered]@{
        collection_completed = $true
        check_count = $checks.Count
        expected_check_count = $ExpectedCheckCount
        pass_count = $passCount
        warn_count = $warnCount
        fail_count = $failCount
        observed_action_count = $observedActionIds.Count
        observed_action_ids = @($observedActionIds.ToArray())
        read_only = $true
        no_admin_required = $true
        remediation_performed = $false
        mutation_performed = $false
    }

    Write-NetworkEvidenceResult -ActionId $ActionId -Result $resultValue -Message $message -Evidence $evidence -EvidenceText $message

    if ($failCount -gt 0) { exit 1 }
    exit 0
}
catch {
    $safeError = $_.Exception.GetType().Name
    $evidence = [ordered]@{
        collection_completed = $false
        error_category = $safeError
    }

    Write-NetworkEvidenceResult -ActionId $ActionId -Result 'FAIL' -Message 'Network evidence runner failed before completion.' -Evidence $evidence -EvidenceText 'Network evidence runner failed before completion.'
    exit 1
}