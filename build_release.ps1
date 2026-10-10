# Builds a signed Play release AAB with V2 + RevenueCat Android public SDK key.
# Reads REVENUECAT_ANDROID_API_KEY from repo-root .env (gitignored).
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoRoot

$envFile = Join-Path $repoRoot '.env'
if (-not (Test-Path $envFile)) {
    Write-Error "Missing .env at repo root. Copy .env.example to .env and set REVENUECAT_ANDROID_API_KEY."
    exit 1
}

$key = $null
foreach ($line in Get-Content $envFile) {
    $trimmed = $line.Trim()
    if ($trimmed.StartsWith('#') -or [string]::IsNullOrWhiteSpace($trimmed)) {
        continue
    }
    if ($trimmed -match '^\s*REVENUECAT_ANDROID_API_KEY\s*=\s*(.+)\s*$') {
        $key = $Matches[1].Trim().Trim('"').Trim("'")
        break
    }
}

if ([string]::IsNullOrWhiteSpace($key) -or $key -match 'your_revenuecat|placeholder|xxx') {
    Write-Error "REVENUECAT_ANDROID_API_KEY is missing or still a placeholder in .env"
    exit 1
}

Write-Host "Building release AAB (V3, REVENUECAT_ANDROID_API_KEY set)..."
flutter build appbundle --release `
    --dart-define=REVENUECAT_ANDROID_API_KEY=$key

if ($LASTEXITCODE -ne 0) {
    Write-Error "flutter build appbundle failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

$aab = Join-Path $repoRoot 'build\app\outputs\bundle\release\app-release.aab'
Write-Host "AAB: $aab"
