param(
  [string]$Root = "C:\update-test",
  [int]$Port = 8080
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $Root)) {
  Write-Error "Root not found: $Root (run setup-test-env.ps1 first)"
}

$python = Get-Command python -ErrorAction SilentlyContinue
if ($python) {
  Write-Host "Serving $Root on http://localhost:$Port/ (python http.server)"
  Push-Location $Root
  try {
    python -m http.server $Port --bind 127.0.0.1
  } finally {
    Pop-Location
  }
  return
}

Write-Host "Python not found; using .NET HttpListener on http://localhost:$Port/"
$listener = New-Object System.Net.HttpListener
$prefix = "http://127.0.0.1:$Port/"
$listener.Prefixes.Add($prefix)
$listener.Start()

while ($listener.IsListening) {
  $context = $listener.GetContext()
  $rel = $context.Request.Url.LocalPath.TrimStart('/')
  if ([string]::IsNullOrWhiteSpace($rel)) { $rel = "version.json" }
  $file = Join-Path $Root $rel
  $response = $context.Response
  $response.Headers.Add("Cache-Control", "no-cache, max-age=0")
  if (Test-Path $file -PathType Leaf) {
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $response.StatusCode = 200
    if ($file.EndsWith(".json")) {
      $response.ContentType = "application/json"
    } else {
      $response.ContentType = "application/octet-stream"
    }
    $response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $response.StatusCode = 404
  }
  $response.Close()
}
