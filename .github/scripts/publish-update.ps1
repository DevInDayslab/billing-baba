# Publishes Windows update artifacts to S3-compatible public hosting.
param(
  [string]$DistDir = "dist",
  [string]$Version = $env:APP_VERSION,
  [switch]$DryRun,
  [switch]$PruneOnly,
  [switch]$SimulatePruneFailure,
  [switch]$SimulateInstallerUploadFailure,
  [switch]$SimulateManifestUploadFailure
)

$ErrorActionPreference = "Stop"

$PruneLogicPath = Join-Path $PSScriptRoot "update-prune-logic.ps1"
. $PruneLogicPath

function Require-Env([string]$Name) {
  $value = [Environment]::GetEnvironmentVariable($Name)
  if ([string]::IsNullOrWhiteSpace($value)) {
    Write-Error "Missing required environment variable or secret: $Name"
  }
  return $value
}

function Assert-UpdateHostsMatch {
  param(
    [string]$ManifestUrl,
    [string]$DownloadBaseUrl
  )

  if ([string]::IsNullOrWhiteSpace($ManifestUrl)) {
    Write-Error "UPDATE_MANIFEST_URL is required"
  }
  if ([string]::IsNullOrWhiteSpace($DownloadBaseUrl)) {
    Write-Error "UPDATE_DOWNLOAD_BASE_URL is required"
  }

  $mHost = ([Uri]$ManifestUrl).Host
  $dHost = ([Uri]$DownloadBaseUrl.TrimEnd('/')).Host
  if ($mHost -ne $dHost) {
    Write-Error "UPDATE_MANIFEST_URL host ($mHost) must match UPDATE_DOWNLOAD_BASE_URL host ($dHost)"
  }
}

function Get-S3Args([string]$Endpoint) {
  $s3Args = @()
  if ($Endpoint) {
    $s3Args += @("--endpoint-url", $Endpoint)
  }
  return $s3Args
}

function Get-ProtectedInstallerNames {
  param(
    [string]$NewManifestPath,
    [string]$Bucket,
    [string]$Prefix,
    [string]$Endpoint,
    [string]$TempDir
  )

  $protected = [System.Collections.Generic.HashSet[string]]::new(
    [StringComparer]::OrdinalIgnoreCase
  )

  if (Test-Path $NewManifestPath) {
    try {
      $json = Get-Content -Path $NewManifestPath -Raw -Encoding utf8 | ConvertFrom-Json
      $url = [string]$json.installer_url
      if ($url) {
        $name = [Uri]::new($url).Segments[-1]
        if ($name) { $protected.Add($name) | Out-Null }
      }
    } catch {
      # ignore
    }
  }

  $prefix = $Prefix.Trim('/')
  $manifestKey = if ($prefix) { "$prefix/version.json" } else { "version.json" }
  $prevPath = Join-Path $TempDir "previous-version.json"
  $s3Args = Get-S3Args -Endpoint $Endpoint

  try {
    aws s3 cp "s3://$Bucket/$manifestKey" $prevPath @s3Args 2>$null | Out-Null
    if (Test-Path $prevPath) {
      $prev = Get-Content -Path $prevPath -Raw -Encoding utf8 | ConvertFrom-Json
      $prevUrl = [string]$prev.installer_url
      if ($prevUrl) {
        $prevName = [Uri]::new($prevUrl).Segments[-1]
        if ($prevName) { $protected.Add($prevName) | Out-Null }
      }
    }
  } catch {
    # previous live manifest unavailable — ok
  }

  return @($protected)
}

function Invoke-InstallerPrune {
  param(
    [string]$Bucket,
    [string]$Prefix,
    [string]$Endpoint,
    [string]$NewManifestPath,
    [switch]$DryRun,
    [switch]$SimulateFailure
  )

  $prefix = $Prefix.Trim('/')
  if ([string]::IsNullOrWhiteSpace($prefix)) {
    Write-Warning "::warning::Prune skipped: empty prefix"
    return
  }

  $listPrefix = "$prefix/"
  $s3Args = Get-S3Args -Endpoint $Endpoint
  $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("bb-prune-" + [Guid]::NewGuid().ToString("n"))
  New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

  try {
    if ($SimulateFailure) {
      throw [System.InvalidOperationException]::new('Simulated prune failure')
    }

    $json = aws s3api list-objects-v2 --bucket $Bucket --prefix $listPrefix @s3Args | ConvertFrom-Json
    $installerNames = @()
    $nameToKey = @{}
    foreach ($item in @($json.Contents)) {
      $key = [string]$item.Key
      $name = Split-Path $key -Leaf
      if (Test-UpdateInstallerObjectName -Name $name) {
        $installerNames += $name
        $nameToKey[$name] = $key
      }
    }

    $protected = Get-ProtectedInstallerNames `
      -NewManifestPath $NewManifestPath `
      -Bucket $Bucket `
      -Prefix $prefix `
      -Endpoint $Endpoint `
      -TempDir $tempDir

    $plan = Get-InstallerPrunePlan `
      -InstallerNames $installerNames `
      -ProtectedNames $protected

    if ($plan.Warning) {
      Write-Warning "::warning::Prune skipped: $($plan.Warning)"
      return
    }

    foreach ($name in $plan.DeleteNames) {
      $key = $nameToKey[$name]
      if (-not $key) { continue }
      if ($DryRun) {
        Write-Host "[DryRun] Would delete old installer s3://$Bucket/$key"
      } else {
        Write-Host "Deleting old installer s3://$Bucket/$key"
        aws s3 rm "s3://$Bucket/$key" @s3Args
      }
    }
  } catch {
    $short = $_.Exception.Message
    if ($short.Length -gt 200) { $short = $short.Substring(0, 200) }
    Write-Warning "::warning::Prune skipped: $short"
  } finally {
    Remove-Item -Recurse -Force -Path $tempDir -ErrorAction SilentlyContinue
  }
}

function Invoke-UploadArtifacts {
  param(
    [string]$Bucket,
    [string]$Prefix,
    [string]$InstallerLocalPath,
    [string]$ManifestLocalPath,
    [string]$Endpoint,
    [switch]$DryRun,
    [switch]$SimulateInstallerUploadFailure,
    [switch]$SimulateManifestUploadFailure
  )

  $prefix = $Prefix.Trim('/')
  $installerKey = if ($prefix) { "$prefix/$(Split-Path $InstallerLocalPath -Leaf)" } else { Split-Path $InstallerLocalPath -Leaf }
  $manifestKey = if ($prefix) { "$prefix/version.json" } else { "version.json" }

  $s3Args = Get-S3Args -Endpoint $Endpoint

  if ($SimulateInstallerUploadFailure) {
    Write-Error "Simulated installer upload failure"
  }

  if ($DryRun) {
    Write-Host "[DryRun] Would upload installer to s3://$Bucket/$installerKey"
  } else {
    Write-Host "Uploading installer to s3://$Bucket/$installerKey"
    aws s3 cp $InstallerLocalPath "s3://$Bucket/$installerKey" `
      @s3Args `
      --cache-control "public, max-age=31536000, immutable" `
      --content-type "application/octet-stream"
  }

  if ($SimulateManifestUploadFailure) {
    Write-Error "Simulated manifest upload failure"
  }

  if ($DryRun) {
    Write-Host "[DryRun] Would upload manifest LAST to s3://$Bucket/$manifestKey"
  } else {
    Write-Host "Uploading manifest to s3://$Bucket/$manifestKey"
    aws s3 cp $ManifestLocalPath "s3://$Bucket/$manifestKey" `
      @s3Args `
      --cache-control "no-cache, max-age=0" `
      --content-type "application/json"
  }
}

if (-not $Version) {
  Write-Error "APP_VERSION is required"
}

$installerName = "BillingBabaSetup-v$Version.exe"
$installerPath = Join-Path $DistDir $installerName
$manifestPath = Join-Path $DistDir "version.json"

foreach ($path in @($installerPath, $manifestPath)) {
  if (-not (Test-Path $path)) {
    Write-Error "Missing artifact: $path"
  }
}

$manifestUrl = Require-Env "UPDATE_MANIFEST_URL"
$downloadBase = Require-Env "UPDATE_DOWNLOAD_BASE_URL"
Assert-UpdateHostsMatch -ManifestUrl $manifestUrl -DownloadBaseUrl $downloadBase

$bucket = Require-Env "UPDATE_S3_BUCKET"
$accessKey = Require-Env "UPDATE_S3_ACCESS_KEY_ID"
$secretKey = Require-Env "UPDATE_S3_SECRET_ACCESS_KEY"
$prefix = [Environment]::GetEnvironmentVariable("UPDATE_S3_PATH_PREFIX")
if ([string]::IsNullOrWhiteSpace($prefix)) {
  $prefix = "updates/windows"
}
$endpoint = [Environment]::GetEnvironmentVariable("UPDATE_S3_ENDPOINT")

$env:AWS_ACCESS_KEY_ID = $accessKey
$env:AWS_SECRET_ACCESS_KEY = $secretKey
$env:AWS_DEFAULT_REGION = "auto"
# Railway and most S3-compatible stores use path-style addressing (matches API S3_FORCE_PATH_STYLE).
$forcePathStyle = [Environment]::GetEnvironmentVariable("UPDATE_S3_FORCE_PATH_STYLE")
if ($forcePathStyle -eq 'false' -or $forcePathStyle -eq 'False') {
  $env:AWS_S3_ADDRESSING_STYLE = "virtual"
} else {
  $env:AWS_S3_ADDRESSING_STYLE = "path"
}

if ($PruneOnly) {
  Invoke-InstallerPrune `
    -Bucket $bucket `
    -Prefix $prefix `
    -Endpoint $endpoint `
    -NewManifestPath $manifestPath `
    -DryRun:$DryRun `
    -SimulateFailure:$SimulatePruneFailure
  if ($DryRun) {
    Write-Host "DryRun prune step complete."
  } else {
    Write-Host "Prune step complete."
  }
  exit 0
}

Invoke-UploadArtifacts `
  -Bucket $bucket `
  -Prefix $prefix `
  -InstallerLocalPath $installerPath `
  -ManifestLocalPath $manifestPath `
  -Endpoint $endpoint `
  -DryRun:$DryRun `
  -SimulateInstallerUploadFailure:$SimulateInstallerUploadFailure `
  -SimulateManifestUploadFailure:$SimulateManifestUploadFailure

if ($DryRun) {
  Write-Host "DryRun upload complete (prune runs in a separate -PruneOnly step after website hook)."
} else {
  Write-Host "Upload complete (prune runs in a separate -PruneOnly step after website hook)."
}
