param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,
  [string]$ManifestUrl = "http://localhost:8080/version.json"
)

$ErrorActionPreference = "Stop"
Push-Location (Join-Path $RepoRoot "apps\client")
flutter run -d windows `
  --dart-define=UPDATE_MANIFEST_URL=$ManifestUrl `
  --dart-define=UPDATE_MANIFEST_ALLOW_HTTP=true
