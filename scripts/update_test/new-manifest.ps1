param(
  [Parameter(Mandatory = $true)]
  [string]$Version,
  [Parameter(Mandatory = $true)]
  [int]$Build,
  [Parameter(Mandatory = $true)]
  [string]$InstallerFile,
  [string]$Url = "http://localhost:8080/version.json",
  [switch]$Force,
  [int]$MinBuild = 1,
  [switch]$BadHash,
  [string]$OutDir = "C:\update-test"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $InstallerFile)) {
  Write-Error "Installer file not found: $InstallerFile"
}

$hash = if ($BadHash) {
  "0000000000000000000000000000000000000000000000000000000000000000"
} else {
  (Get-FileHash -Path $InstallerFile -Algorithm SHA256).Hash.ToLower()
}

$installerName = Split-Path $InstallerFile -Leaf
$base = ($Url -replace '/version\.json$', '').TrimEnd('/')
$installerUrl = "$base/$installerName"

$manifest = [ordered]@{
  latest_version = $Version
  latest_build = $Build
  min_supported_build = $MinBuild
  installer_url = $installerUrl
  sha256 = $hash
  release_notes = "Local test manifest for $Version+$Build"
  force_update = [bool]$Force
  published_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$outPath = Join-Path $OutDir "version.json"
$manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $outPath -Encoding utf8
Write-Host "Wrote $outPath (sha256=$hash)"
