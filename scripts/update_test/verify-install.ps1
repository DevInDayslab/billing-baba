param(
  [string]$ExpectedVersion = "1.0.1",
  [string]$InstallDir = "$env:LOCALAPPDATA\Programs\Billing Baba",
  [string]$DataRoot = "$env:LOCALAPPDATA\BillingBaba"
)

$ErrorActionPreference = "Stop"

function Result([string]$Name, [bool]$Ok, [string]$Detail) {
  $status = if ($Ok) { "PASS" } else { "FAIL" }
  Write-Host "[$status] $Name — $Detail"
}

$exe = Join-Path $InstallDir "billing_baba.exe"
if (Test-Path $exe) {
  $ver = (Get-Item $exe).VersionInfo.FileVersion
  Result "File version" ($ver -eq $ExpectedVersion) "expected $ExpectedVersion, got $ver"
} else {
  Result "File version" $false "missing $exe"
}

$proc = Get-Process -Name "billing_baba" -ErrorAction SilentlyContinue
Result "Process running" ($null -ne $proc) ($(if ($proc) { "PID $($proc.Id)" } else { "not running" }))

$db = Join-Path $DataRoot "databases\billing_baba.sqlite"
if (Test-Path $db) {
  $len = (Get-Item $db).Length
  Result "SQLite exists" ($len -gt 0) "size=$len bytes"
  $copy = Join-Path $env:TEMP "billing_baba_verify_copy.sqlite"
  Copy-Item -Force $db $copy
  Result "SQLite copy" (Test-Path $copy) $copy
} else {
  Result "SQLite exists" $false "missing $db"
}

$backupDir = Join-Path $DataRoot "auto_backups"
if (Test-Path $backupDir) {
  $files = Get-ChildItem $backupDir -Filter *.biba | Sort-Object LastWriteTime -Descending
  Write-Host "auto_backups ($($files.Count) file(s)):"
  foreach ($f in $files) { Write-Host "  $($f.Name) ($($f.Length) bytes)" }
} else {
  Write-Host "auto_backups: (directory missing)"
}
