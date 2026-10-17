$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "update-prune-logic.ps1")

function Assert-Equal($a, $b, [string]$label) {
  $aStr = ($a | Sort-Object) -join ','
  $bStr = ($b | Sort-Object) -join ','
  if ($aStr -ne $bStr) {
    Write-Error "FAIL $label - expected [$bStr] got [$aStr]"
  }
  Write-Host "PASS $label"
}

# (a) 10 installers, current = newest -> deletes 5 oldest
$names10 = 0..9 | ForEach-Object { "BillingBabaSetup-v1.$_.0.exe" }
$planA = Get-InstallerPrunePlan -InstallerNames $names10 -ProtectedNames @("BillingBabaSetup-v1.9.0.exe")
Assert-Equal $planA.DeleteNames @(
  'BillingBabaSetup-v1.0.0.exe',
  'BillingBabaSetup-v1.1.0.exe',
  'BillingBabaSetup-v1.2.0.exe',
  'BillingBabaSetup-v1.3.0.exe',
  'BillingBabaSetup-v1.4.0.exe'
) "10 installers keep 5 newest"

# (b) rollback - protect old installer referenced by previous manifest
$namesRb = 0..9 | ForEach-Object { "BillingBabaSetup-v1.$_.0.exe" }
$planB = Get-InstallerPrunePlan -InstallerNames $namesRb -ProtectedNames @(
  'BillingBabaSetup-v1.9.0.exe',
  'BillingBabaSetup-v1.3.0.exe'
)
if ($planB.DeleteNames -contains 'BillingBabaSetup-v1.3.0.exe') {
  Write-Error "FAIL rollback must protect previous manifest installer"
}
if ($planB.DeleteNames.Count -lt 1) {
  Write-Error "FAIL rollback should still prune older unprotected installers"
}
Write-Host "PASS rollback protects previous manifest installer"

# (c) unrelated file names are never considered installers
$planC = Get-InstallerPrunePlan -InstallerNames @(
  'version.json',
  'SHA256SUMS.txt',
  'BillingBabaSetup-vfoo.exe',
  'BillingBabaSetup-v1.0.0.exe',
  'BillingBabaSetup-v1.1.0.exe',
  'BillingBabaSetup-v1.2.0.exe'
)
Assert-Equal $planC.DeleteNames @() "non-matching names ignored"

# (d) fewer than 5 installers -> deletes nothing
$planD = Get-InstallerPrunePlan -InstallerNames @(
  'BillingBabaSetup-v1.0.0.exe',
  'BillingBabaSetup-v1.1.0.exe',
  'BillingBabaSetup-v1.2.0.exe'
)
if ($planD.DeleteNames.Count -ne 0) {
  Write-Error "FAIL fewer than 5 installers"
}
Write-Host "PASS fewer than 5 installers deletes nothing"

# (e) invalid name ignored
$planE = Get-InstallerPrunePlan -InstallerNames @('BillingBabaSetup-vfoo.exe')
if ($null -ne $planE.Warning -and $planE.DeleteNames.Count -eq 0) {
  Write-Host "PASS non-semver name ignored"
} else {
  Write-Error "FAIL non-semver name"
}

# (f) semver 1.10.0 > 1.9.0
$planF = Get-InstallerPrunePlan -InstallerNames @(
  'BillingBabaSetup-v1.9.0.exe',
  'BillingBabaSetup-v1.10.0.exe',
  'BillingBabaSetup-v1.8.0.exe',
  'BillingBabaSetup-v1.7.0.exe',
  'BillingBabaSetup-v1.6.0.exe',
  'BillingBabaSetup-v1.5.0.exe',
  'BillingBabaSetup-v1.4.0.exe'
) -ProtectedNames @('BillingBabaSetup-v1.10.0.exe')
Assert-Equal $planF.DeleteNames @(
  'BillingBabaSetup-v1.5.0.exe',
  'BillingBabaSetup-v1.4.0.exe'
) "semver ordering 1.10.0 newest"

Write-Host "All prune logic tests passed."
