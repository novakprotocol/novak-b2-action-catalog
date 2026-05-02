$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Scripts = Get-ChildItem -Path $Root -Recurse -Filter "*.ps1" | Where-Object { $_.FullName -notmatch "\\.git\\" }
$Failed = @()

foreach ($Script in $Scripts) {
    $Errors = $null
    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw -LiteralPath $Script.FullName), [ref]$Errors)
    if ($Errors -and $Errors.Count -gt 0) {
        Write-Host "FAIL syntax $($Script.FullName): $($Errors[0].Message)"
        $Failed += $Script.FullName
    }
}

if ($Failed.Count -gt 0) { exit 1 }
Write-Host "PASS PowerShell syntax scripts=$($Scripts.Count)"
