# Manual build cases (e)-(f): invalid JSON and host mismatch via local HTTP server.
$ErrorActionPreference = "Stop"
$website = Split-Path $PSScriptRoot -Parent
$job = Start-Job -ScriptBlock {
  param($root)
  Set-Location $root
  python -c @"
import json
from http.server import BaseHTTPRequestHandler, HTTPServer
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.endswith('bad.json'):
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'not-json')
        elif self.path.endswith('mismatch.json'):
            body = json.dumps({
              'latest_version':'1.0.0','latest_build':1,'min_supported_build':1,
              'installer_url':'https://evil.example.com/BillingBabaSetup-v1.0.0.exe',
              'sha256':'abc','release_notes':'x','force_update':False,
              'published_at':'2026-01-01T00:00:00Z'
            }).encode()
            self.send_response(200)
            self.end_headers()
            self.wfile.write(body)
        else:
            self.send_response(404)
            self.end_headers()
    def log_message(self, *args): pass
HTTPServer(('127.0.0.1', 8765), H).serve_forever()
"@
} -ArgumentList $website

Start-Sleep -Seconds 2

function Run-Case([string]$label, [string]$url) {
  $env:WEBSITE_UPDATE_MANIFEST_URL = $url
  Push-Location $website
  bun run scripts/fetch-windows-release.ts
  $code = $LASTEXITCODE
  Write-Host "--- snapshot for $label (fetch exit $code) ---"
  Get-Content src/generated/windows-release.snapshot.json
  bun run build
  $buildCode = $LASTEXITCODE
  Pop-Location
  if ($buildCode -ne 0) { throw "Build failed for $label" }
  Write-Host "PASS $label build exit $buildCode"
}

Run-Case "(e) invalid JSON" "http://127.0.0.1:8765/bad.json"
Run-Case "(f) host mismatch" "http://127.0.0.1:8765/mismatch.json"

Stop-Job $job -ErrorAction SilentlyContinue
Remove-Job $job -Force -ErrorAction SilentlyContinue
