# Uploads updates/windows/smoke-test.json and verifies anonymous HTTPS GET via PublicBaseUrl.
param(
  [Parameter(Mandatory)]
  [string]$PublicBaseUrl,

  [Parameter(Mandatory)]
  [string]$Endpoint,

  [Parameter(Mandatory)]
  [string]$Bucket,

  [Parameter(Mandatory)]
  [string]$AccessKeyId,

  [Parameter(Mandatory)]
  [string]$SecretAccessKey,

  # Skip S3 upload; only test anonymous GET (e.g. after uploading via Railway UI).
  [switch]$SkipUpload,

  [string]$Prefix = "updates/windows"
)

$ErrorActionPreference = "Stop"

function Resolve-AwsCliPath {
  $cmd = Get-Command aws -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  $defaultPath = Join-Path ${env:ProgramFiles} "Amazon\AWSCLIV2\aws.exe"
  if (Test-Path $defaultPath) { return $defaultPath }
  throw @"
AWS CLI (aws) is not installed or not on PATH.

Install (Windows):
  winget install -e --id Amazon.AWSCLI

Then close and reopen PowerShell, or use the full path:
  & `"$defaultPath`" --version
"@
}

$awsCli = Resolve-AwsCliPath

$AccessKeyId = $AccessKeyId.Trim()
$SecretAccessKey = $SecretAccessKey.Trim()

if ($AccessKeyId -match '^\^V$|^\.\.\.$|YOUR|PASTE') {
  throw "AccessKeyId looks like a placeholder. Paste the full tid_... value from Railway public files → Credentials."
}
if ($PublicBaseUrl -match 'PASTE|YOUR-REAL-PRESIGNER') {
  throw "PublicBaseUrl is still a placeholder. Use billing-baba-public-presigner → Settings → Networking → public HTTPS domain."
}

$publicBase = $PublicBaseUrl.Trim().TrimEnd('/')
if ($publicBase -notmatch '^https?://') {
  $publicBase = "https://$publicBase"
  Write-Host "PublicBaseUrl normalized to: $publicBase" -ForegroundColor DarkGray
}
$prefix = $Prefix.Trim('/')
$key = "$prefix/smoke-test.json"
$publicUrl = "$publicBase/$key"

$body = @{
  smoke_test = $true
  note = "Delete after smoke-public-update-bucket.ps1 succeeds"
  checked_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
} | ConvertTo-Json -Compress

$tempFile = Join-Path $env:TEMP ("bb-smoke-" + [Guid]::NewGuid().ToString("n") + ".json")
Set-Content -Path $tempFile -Value $body -Encoding utf8 -NoNewline

$env:AWS_ACCESS_KEY_ID = $AccessKeyId
$env:AWS_SECRET_ACCESS_KEY = $SecretAccessKey
$env:AWS_DEFAULT_REGION = "auto"
$env:AWS_S3_ADDRESSING_STYLE = "path"

if (-not $SkipUpload) {
  Write-Host "Uploading s3://$Bucket/$key ..."
  & $awsCli s3 cp $tempFile "s3://$Bucket/$key" `
    --endpoint-url $Endpoint `
    --content-type "application/json" `
    --cache-control "no-cache, max-age=0"
} else {
  Write-Host "SkipUpload: not uploading (expect object already at s3://$Bucket/$key)" -ForegroundColor DarkGray
}

Remove-Item -Force -Path $tempFile -ErrorAction SilentlyContinue

Write-Host "Anonymous GET $publicUrl"
try {
  $response = Invoke-WebRequest -Uri $publicUrl -UseBasicParsing -Method Get
} catch {
  Write-Error @"
Anonymous GET failed: $($_.Exception.Message)

Check:
  - PUBLIC_BASE matches how clients reach objects (presigner domain vs bucket URL)
  - Object key is $key
  - Bucket or presigner allows public read for $prefix/*
"@
}

if ($response.StatusCode -ne 200) {
  Write-Error "Expected HTTP 200, got $($response.StatusCode)"
}

if ($response.Content -notmatch 'smoke_test') {
  Write-Error "Response body did not contain smoke_test JSON. Body starts with: $($response.Content.Substring(0, [Math]::Min(120, $response.Content.Length)))"
}

Write-Host "[OK] Anonymous GET works for $prefix/" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Set GitHub UPDATE_* variables/secrets (see docs/deployment/auto-update-public-bucket-cutover.md)"
Write-Host "  2. Run Build Demo or publish-update.ps1 to upload version.json + installer"
Write-Host "  3. verify-update-hosting.ps1 -ManifestUrl `"$publicBase/$prefix/version.json`""
Write-Host ""
Write-Host "Optional: delete smoke object:" -ForegroundColor DarkGray
Write-Host "  & `"$awsCli`" s3 rm s3://$Bucket/$key --endpoint-url $Endpoint"
