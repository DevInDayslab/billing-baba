param(
  [Parameter(Mandatory = $true)]
  [string]$ManifestUrlHttps,
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,
  [string]$IsccPath = "ISCC.exe",
  [string]$OutDir = "C:\update-test"
)

$ErrorActionPreference = "Stop"
$pubspec = Join-Path $RepoRoot "apps\client\pubspec.yaml"
$iss = Join-Path $RepoRoot "installer\BillingBaba.iss"
$client = Join-Path $RepoRoot "apps\client"

if (-not (Test-Path $pubspec)) { Write-Error "pubspec not found: $pubspec" }

$originalPubspec = Get-Content -Path $pubspec -Raw -Encoding utf8
$gitDiffBefore = (git -C $RepoRoot diff -- apps/client/pubspec.yaml)

function Set-PubspecVersion([string]$versionLine) {
  $content = Get-Content -Path $pubspec -Raw -Encoding utf8
  $content = [regex]::Replace($content, '(?m)^version:\s*.*$', "version: $versionLine")
  Set-Content -Path $pubspec -Value $content -Encoding utf8 -NoNewline
}

function Build-One([string]$VersionPlus, [string]$AppVersion, [string]$OutName) {
  if ($VersionPlus -notmatch '^(.+)\+(\d+)$') {
    Write-Error "VersionPlus must be semver+build (e.g. 1.0.0+1), got: $VersionPlus"
  }
  $buildName = $Matches[1]
  $buildNumber = $Matches[2]
  $expectedFileVersion = "$buildName+$buildNumber"

  Set-PubspecVersion $VersionPlus
  Push-Location $client
  try {
    # Incremental Windows builds can keep the previous exe's version resources when
    # only pubspec changes — always pass explicit build name/number for test kits.
    flutter build windows --release `
      --build-name=$buildName `
      --build-number=$buildNumber `
      --dart-define=UPDATE_MANIFEST_URL=$ManifestUrlHttps `
      --dart-define=UPDATE_MANIFEST_ALLOW_HTTP=true
  } finally {
    Pop-Location
  }
  $releaseDir = Join-Path $client "build\windows\x64\runner\Release"
  $builtExe = Join-Path $releaseDir "billing_baba.exe"
  if (-not (Test-Path $builtExe)) {
    Write-Error "Missing built exe: $builtExe"
  }
  $actualFileVersion = (Get-Item $builtExe).VersionInfo.FileVersion
  if ($actualFileVersion -ne $expectedFileVersion) {
    Write-Error @"
billing_baba.exe version mismatch before packaging $OutName.
  Expected: $expectedFileVersion
  Actual:   $actualFileVersion
Run 'flutter clean' in apps/client and rebuild this script.
"@
  }
  Write-Host "Verified $builtExe => $actualFileVersion"
  if (-not (Get-Command $IsccPath -ErrorAction SilentlyContinue)) {
    Write-Error "Inno Setup compiler not found ($IsccPath)"
  }
  & $IsccPath "/DAppVersion=$AppVersion" "/DReleaseDir=$releaseDir" "/DOutputDir=$OutDir" $iss
  $built = Join-Path $OutDir "BillingBabaSetup-v$AppVersion.exe"
  if (-not (Test-Path $built)) {
    Write-Error "Expected installer at $built"
  }
  if ($OutName -ne "BillingBabaSetup-v$AppVersion.exe") {
    Copy-Item -Force $built (Join-Path $OutDir $OutName)
  }
}

try {
  New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
  Push-Location $client
  try {
    Write-Host "Cleaning Windows build output so each installer gets the correct version..."
    flutter clean
  } finally {
    Pop-Location
  }
  Build-One "1.0.0+1" "1.0.0" "BillingBabaSetup-v1.0.0.exe"
  Build-One "1.0.1+2" "1.0.1" "BillingBabaSetup-v1.0.1.exe"
} finally {
  Set-Content -Path $pubspec -Value $originalPubspec -Encoding utf8 -NoNewline
  $gitDiffAfter = git -C $RepoRoot diff -- apps/client/pubspec.yaml
  if ($gitDiffAfter) {
    Write-Error "pubspec.yaml was not restored cleanly; git diff:`n$gitDiffAfter"
  }
  Write-Host "pubspec.yaml restored (no git diff)."
}
