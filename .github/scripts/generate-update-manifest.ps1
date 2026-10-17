# Writes dist/version.json for the desktop auto-updater (public hosting).
param(
  [string]$PubspecPath = "apps/client/pubspec.yaml",
  [string]$DistDir = "dist",
  [string]$DownloadBaseUrl = $env:UPDATE_DOWNLOAD_BASE_URL,
  [bool]$ForceUpdate = ($env:FORCE_UPDATE -eq 'true' -or $env:FORCE_UPDATE -eq 'True'),
  [int]$MinSupportedBuild = $(if ($env:MIN_SUPPORTED_BUILD) { [int]$env:MIN_SUPPORTED_BUILD } else { 1 })
)

$ErrorActionPreference = "Stop"

if (-not $DownloadBaseUrl) {
  Write-Error "UPDATE_DOWNLOAD_BASE_URL is required"
}

$manifestUrlEnv = $env:UPDATE_MANIFEST_URL
if ($manifestUrlEnv) {
  $mHost = ([Uri]$manifestUrlEnv).Host
  $dHost = ([Uri]$DownloadBaseUrl.TrimEnd('/')).Host
  if ($mHost -ne $dHost) {
    Write-Error "UPDATE_MANIFEST_URL host ($mHost) must match UPDATE_DOWNLOAD_BASE_URL host ($dHost)"
  }
}

$line = Select-String -Path $PubspecPath -Pattern '^version:' | Select-Object -First 1
if (-not $line) {
  Write-Error "Could not find version in $PubspecPath"
}

$raw = ($line.Line -replace 'version:\s*', '').Trim()
$parts = $raw.Split('+')
$version = $parts[0]
$build = if ($parts.Length -gt 1) { [int]$parts[1] } else { 1 }

$base = $DownloadBaseUrl.TrimEnd('/')
$installerName = "BillingBabaSetup-v$version.exe"
$installerPath = Join-Path $DistDir $installerName

if (-not (Test-Path $installerPath)) {
  Write-Error "Installer not found at $installerPath"
}

$sha256 = (Get-FileHash -Path $installerPath -Algorithm SHA256).Hash.ToLower()

$notesPath = "docs/release-notes/$version.md"
$releaseNotes = "Bug fixes and improvements"
if (Test-Path $notesPath) {
  $releaseNotes = Get-Content -Path $notesPath -Raw -Encoding utf8
}

$manifest = [ordered]@{
  latest_version = $version
  latest_build = $build
  min_supported_build = $MinSupportedBuild
  installer_url = "$base/$installerName"
  sha256 = $sha256
  release_notes = $releaseNotes.Trim()
  force_update = $ForceUpdate
  published_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

$outPath = Join-Path $DistDir "version.json"
$manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $outPath -Encoding utf8
Write-Host "Wrote $outPath"
