# Prints GitHub Actions variable/secret mapping from Railway API S3 env vars.
# Usage (PowerShell): set S3_PUBLIC_BASE_URL, S3_ENDPOINT, S3_BUCKET, then run this script.
param(
  [string]$Prefix = "updates/windows"
)

$ErrorActionPreference = "Stop"

$publicBase = $env:S3_PUBLIC_BASE_URL
if ([string]::IsNullOrWhiteSpace($publicBase)) {
  Write-Error "Set S3_PUBLIC_BASE_URL in the current session (copy from Railway API variables)."
}
$publicBase = $publicBase.TrimEnd('/')
$prefix = $Prefix.Trim('/')

Write-Host ""
Write-Host "=== GitHub Actions VARIABLES (paste in repo Settings) ===" -ForegroundColor Cyan
Write-Host "UPDATE_MANIFEST_URL=$publicBase/$prefix/version.json"
Write-Host "UPDATE_DOWNLOAD_BASE_URL=$publicBase/$prefix"
Write-Host "UPDATE_S3_PATH_PREFIX=$prefix"
Write-Host ""
Write-Host "=== GitHub Actions SECRETS (same values as Railway API) ===" -ForegroundColor Cyan
Write-Host "UPDATE_S3_BUCKET          <- S3_BUCKET"
Write-Host "UPDATE_S3_ACCESS_KEY_ID   <- S3_ACCESS_KEY_ID"
Write-Host "UPDATE_S3_SECRET_ACCESS_KEY <- S3_SECRET_ACCESS_KEY"
Write-Host "UPDATE_S3_ENDPOINT        <- S3_ENDPOINT"
Write-Host "WEBSITE_DEPLOY_HOOK_URL   <- Vercel deploy hook (optional)"
Write-Host ""
Write-Host "=== Vercel production env ===" -ForegroundColor Cyan
Write-Host "WEBSITE_UPDATE_MANIFEST_URL=$publicBase/$prefix/version.json"
Write-Host ""

if ($env:S3_BUCKET) {
  Write-Host "Detected S3_BUCKET=$($env:S3_BUCKET)" -ForegroundColor DarkGray
}
if ($env:S3_ENDPOINT) {
  Write-Host "Detected S3_ENDPOINT=$($env:S3_ENDPOINT)" -ForegroundColor DarkGray
}
