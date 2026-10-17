# Local smoke test for .github/scripts/generate-update-manifest.ps1
$ErrorActionPreference = "Stop"
$repo = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$tmp = Join-Path $env:TEMP "bb-update-manifest-test"
Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

$pubspec = Join-Path $tmp "pubspec.yaml"
@'
name: billing_baba
version: 1.2.3+45
'@ | Set-Content $pubspec -Encoding utf8

$dist = Join-Path $tmp "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$installer = Join-Path $dist "BillingBabaSetup-v1.2.3.exe"
[System.IO.File]::WriteAllBytes($installer, [byte[]](1, 2, 3, 4))

$env:UPDATE_DOWNLOAD_BASE_URL = "https://cdn.example.com/updates/windows"
$gen = Join-Path $repo ".github\scripts\generate-update-manifest.ps1"
& $gen -PubspecPath $pubspec -DistDir $dist -ForceUpdate:$true -MinSupportedBuild 10

$jsonPath = Join-Path $dist "version.json"
$json = Get-Content $jsonPath -Raw | ConvertFrom-Json
if ($json.latest_version -ne "1.2.3") { throw "version parse failed" }
if ($json.latest_build -ne 45) { throw "build parse failed" }
if ($json.installer_url -ne "https://cdn.example.com/updates/windows/BillingBabaSetup-v1.2.3.exe") {
  throw "installer_url wrong: $($json.installer_url)"
}
$expectedHash = (Get-FileHash $installer -Algorithm SHA256).Hash.ToLower()
if ($json.sha256 -ne $expectedHash) { throw "sha256 mismatch" }
if ($json.force_update -ne $true) { throw "force_update override failed" }
if ($json.min_supported_build -ne 10) { throw "min_supported_build override failed" }
Write-Host "generate-update-manifest.ps1: OK"
