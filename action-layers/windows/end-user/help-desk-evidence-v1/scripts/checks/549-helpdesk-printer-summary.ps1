$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

. (Join-Path $PSScriptRoot "..\lib\Common-HelpDeskEvidenceV1.ps1")

$ActionId = "ENDUSER_HELPDESK_PRINTER_SUMMARY_V1"

try {
    $Evidence = [ordered]@{
        printer_query_succeeded = $false
        printer_provider = "none"
        printer_count = -1
        default_printer_present = $false
        printer_names_collected = $false
        mutation_performed = $false
    }

    try {
        if (Get-Command -Name Get-Printer -ErrorAction SilentlyContinue) {
            $Printers = @(Get-Printer -ErrorAction Stop)

            $Evidence["printer_query_succeeded"] = $true
            $Evidence["printer_provider"] = "Get-Printer"
            $Evidence["printer_count"] = $Printers.Count
            $Evidence["default_printer_present"] = @($Printers | Where-Object { $_.Default -eq $true }).Count -gt 0
        }
        else {
            $Printers = @(Get-CimInstance -ClassName Win32_Printer -ErrorAction Stop)

            $Evidence["printer_query_succeeded"] = $true
            $Evidence["printer_provider"] = "Win32_Printer"
            $Evidence["printer_count"] = $Printers.Count
            $Evidence["default_printer_present"] = @($Printers | Where-Object { $_.Default -eq $true }).Count -gt 0
        }
    }
    catch {
        $Evidence["printer_query_succeeded"] = $false
        $Evidence["printer_provider"] = "unavailable_or_blocked"
        $Evidence["printer_count"] = -1
        $Evidence["default_printer_present"] = $false
        $Evidence["error_sanitized"] = $true
    }

    Write-HelpDeskEvidenceResult -ActionId $ActionId -Result "PASS" -Message "Collected sanitized printer evidence summary without recording printer names or changing the system." -Evidence $Evidence
}
catch {
    $Evidence = [ordered]@{
        error_type = $_.Exception.GetType().FullName
        sanitized = $true
    }

    Write-HelpDeskEvidenceResult -ActionId $ActionId -Result "FAIL" -Message "Printer evidence action failed before completion; error detail was sanitized." -Evidence $Evidence
    exit 1
}
