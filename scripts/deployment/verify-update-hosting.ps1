# Verifies public update hosting: optional upload smoke test + manifest GET check.
param(
  [string]$ManifestUrl,
  [string]$Prefix = "updates/windows",
  [switch]$UploadSmokeTest
)

$ErrorActionPreference = "Stop"

function Test-ManifestUrl([string]$Url) {
  Write-Host "GET $Url"
  try {
    $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -Method Get
  } catch {
    Write-Error "Manifest request failed: $($_.Exception.Message)"
  }
  if ($response.StatusCode -ne 200) {
    Write-Error "Expected HTTP 200, got $($response.StatusCode)"
  }
  $json = $response.Content | ConvertFrom-Json
  $required = @(
    'latest_version', 'latest_build', 'installer_url', 'sha256', 'release_notes'
  )
  foreach ($key in $required) {
    if (-not $json.PSObject.Properties.Name.Contains($key)) {
      Write-Error "Manifest missing field: $key"
    }
  }
  $manifestHost = ([Uri]$Url).Host
  $installerHost = ([Uri]$json.installer_url).Host
  if ($manifestHost -ne $installerHost) {
    Write-Error "Host mismatch: manifest=$manifestHost installer=$installerHost"
  }
  Write-Host "[OK] Manifest valid (latest $($json.latest_version)+$($json.latest_build))" -ForegroundColor Green
  Write-Host "     installer_url=$($json.installer_url)"
  return $json
}

if ($UploadSmokeTest) {
  $endpoint = $env:S3_ENDPOINT
  $bucket = $env:S3_BUCKET
  $accessKey = $env:S3_ACCESS_KEY_ID
  $secretKey = $env:S3_SECRET_ACCESS_KEY
  $publicBase = $env:S3_PUBLIC_BASE_URL

  foreach ($name in @('S3_ENDPOINT', 'S3_BUCKET', 'S3_ACCESS_KEY_ID', 'S3_SECRET_ACCESS_KEY', 'S3_PUBLIC_BASE_URL')) {
    if ([string]::IsNullOrWhiteSpace((Get-Item "Env:$name" -ErrorAction SilentlyContinue).Value)) {
      Write-Error "Set $name in the current session (Railway API values)."
    }
  }

  $publicBase = $publicBase.TrimEnd('/')
  $prefix = $Prefix.Trim('/')
  $key = "$prefix/version.json"
  $testBody = '{"smoke_test":true,"note":"delete after verify-update-hosting"}'
  $tempFile = Join-Path $env:TEMP "bb-update-smoke.json"
  Set-Content -Path $tempFile -Value $testBody -Encoding utf8

  $env:AWS_ACCESS_KEY_ID = $accessKey
  $env:AWS_SECRET_ACCESS_KEY = $secretKey
  $env:AWS_DEFAULT_REGION = "auto"
  $env:AWS_S3_ADDRESSING_STYLE = "path"

  Write-Host "Uploading smoke test to s3://$bucket/$key ..."
  aws s3 cp $tempFile "s3://$bucket/$key" `
    --endpoint-url $endpoint `
    --content-type "application/json" `
    --cache-control "no-cache, max-age=0"

  $smokeUrl = "$publicBase/$key"
  Write-Host "GET $smokeUrl"
  $smokeResponse = Invoke-WebRequest -Uri $smokeUrl -UseBasicParsing -Method Get
  if ($smokeResponse.StatusCode -ne 200) {
    Write-Error "Expected HTTP 200 on public URL, got $($smokeResponse.StatusCode)"
  }
  if ($smokeResponse.Content -notmatch 'smoke_test') {
    Write-Error "Public URL did not return uploaded smoke JSON — check S3_PUBLIC_BASE_URL and public access."
  }
  Write-Host "[OK] Public read works for $prefix/ (smoke object)" -ForegroundColor Green
  Write-Host ""
  Write-Host "Next: set GitHub variables/secrets, then tag v* to publish the real installer + manifest." -ForegroundColor Yellow
  exit 0
}

if ([string]::IsNullOrWhiteSpace($ManifestUrl)) {
  Write-Error "Pass -ManifestUrl or use -UploadSmokeTest with S3_* env vars set."
}

$manifest = Test-ManifestUrl -Url $ManifestUrl

Write-Host "HEAD installer ..."
try {
  Invoke-WebRequest -Uri $manifest.installer_url -Method Head -UseBasicParsing | Out-Null
  Write-Host "[OK] Installer URL reachable" -ForegroundColor Green
} catch {
  Write-Warning "Installer HEAD failed (may still work with GET): $($_.Exception.Message)"
}

Write-Host ""
Write-Host "Done. If you used -UploadSmokeTest, replace version.json with a real manifest on first tag release." -ForegroundColor Yellow
