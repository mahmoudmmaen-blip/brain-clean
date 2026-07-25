#Requires -Version 5.1
<#
.SYNOPSIS
  Builds a signed (or debug-fallback) Play appbundle with optional dart-defines.

.DESCRIPTION
  Reads secrets from environment variables only — never from committed files.
  Leave variables unset to verify an offline release (cloud/billing skipped).

.EXAMPLE
  $env:SUPABASE_URL = 'https://xxxx.supabase.co'
  $env:SUPABASE_ANON_KEY = 'eyJ...'
  $env:REVENUECAT_API_KEY = 'goog_...'
  .\tool\build_release_appbundle.ps1
#>
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)

$defines = @()
function Add-Define([string]$Name) {
  $value = [Environment]::GetEnvironmentVariable($Name)
  if (![string]::IsNullOrWhiteSpace($value)) {
    $script:defines += "--dart-define=$Name=$value"
  }
}

Add-Define 'SUPABASE_URL'
Add-Define 'SUPABASE_ANON_KEY'
Add-Define 'REVENUECAT_API_KEY'

Write-Host 'Building appbundle --release'
if ($defines.Count -eq 0) {
  Write-Host 'No dart-defines set — offline/local mode (Supabase + RevenueCat skipped).'
} else {
  Write-Host ("Passing {0} dart-define(s) (values not printed)." -f $defines.Count)
}

& flutter build appbundle --release @defines
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$bundle = Join-Path $PWD 'build\app\outputs\bundle\release\app-release.aab'
if (Test-Path $bundle) {
  Write-Host "App bundle: $bundle"
} else {
  Write-Warning 'Build finished but app-release.aab was not found at the expected path.'
}
