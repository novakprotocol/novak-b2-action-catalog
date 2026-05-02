$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$scripts = Get-ChildItem -Path (Join-Path $root "scripts\checks") -Filter "*.ps1"
$failed = @()
foreach ($s in $scripts) {
    try {
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw -Path $s.FullName), [ref]$errors)
        if ($errors -and $errors.Count -gt 0) {
            Write-Host "FAIL syntax $($s.Name): $($errors[0].Message)"
            $failed += $s.Name
        } else {
            Write-Host "PASS syntax $($s.Name)"
        }
    } catch {
        Write-Host "FAIL syntax $($s.Name): $($_.Exception.Message)"
        $failed += $s.Name
    }
}
if ($failed.Count -gt 0) { exit 1 }
Write-Host "PASS all syntax checks"
