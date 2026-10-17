# Creates local update test directory layout under C:\update-test\
param(
  [switch]$WhatIf
)

$ErrorActionPreference = "Stop"
$root = "C:\update-test"

if ($WhatIf) {
  Write-Host "WhatIf: would create $root and copy helper scripts"
  exit 0
}

New-Item -ItemType Directory -Force -Path $root | Out-Null
Write-Host "Created $root"
Write-Host "Next: run new-manifest.ps1 and serve.ps1 from this folder."
