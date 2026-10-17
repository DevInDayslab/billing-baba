# Pure installer retention selection for Windows update hosting (no network I/O).

function Test-UpdateInstallerObjectName {
  param([string]$Name)
  return $Name -match '^BillingBabaSetup-v(\d+\.\d+\.\d+)\.exe$'
}

function Get-SemverFromInstallerObjectName {
  param([string]$Name)
  if ($Name -match '^BillingBabaSetup-v(\d+\.\d+\.\d+)\.exe$') {
    return [version]$Matches[1]
  }
  return $null
}

function Get-InstallerPrunePlan {
  <#
    Returns objects to delete (S3 keys or names only — caller maps keys).
    Inputs are installer *file names* (leaf), not full keys.
  #>
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$InstallerNames,
    [string[]]$ProtectedNames = @(),
    [int]$KeepNewestCount = 5,
    [int]$MaxDeletes = 20
  )

  $valid = @()
  foreach ($name in $InstallerNames) {
    if (Test-UpdateInstallerObjectName -Name $name) {
      $ver = Get-SemverFromInstallerObjectName -Name $name
      if ($null -ne $ver) {
        $valid += [PSCustomObject]@{
          Name = $name
          Version = $ver
        }
      }
    }
  }

  if ($valid.Count -eq 0) {
    return @{
      DeleteNames = @()
      Warning = 'No matching installer objects under prefix; prune skipped.'
    }
  }

  if ($valid.Count -le $KeepNewestCount) {
    return @{
      DeleteNames = @()
      Warning = $null
    }
  }

  $protected = [System.Collections.Generic.HashSet[string]]::new(
    [StringComparer]::OrdinalIgnoreCase
  )
  foreach ($p in $ProtectedNames) {
    if ($p -and (Test-UpdateInstallerObjectName -Name $p)) {
      $protected.Add($p) | Out-Null
    }
  }

  $sorted = $valid | Sort-Object Version -Descending
  $keep = [System.Collections.Generic.HashSet[string]]::new(
    [StringComparer]::OrdinalIgnoreCase
  )
  foreach ($p in $protected) {
    $keep.Add($p) | Out-Null
  }
  foreach ($item in ($sorted | Select-Object -First $KeepNewestCount)) {
    $keep.Add($item.Name) | Out-Null
  }

  $delete = @($sorted | Where-Object { -not $keep.Contains($_.Name) } | ForEach-Object { $_.Name })

  if ($delete.Count -eq 0) {
    return @{ DeleteNames = @(); Warning = $null }
  }

  if ($delete.Count -gt $MaxDeletes) {
    return @{
      DeleteNames = @()
      Warning = "Prune aborted: would delete $($delete.Count) objects (limit $MaxDeletes)."
    }
  }

  if ($delete.Count -ge $valid.Count) {
    return @{
      DeleteNames = @()
      Warning = 'Prune aborted: delete list would remove all matching installers.'
    }
  }

  return @{
    DeleteNames = $delete
    Warning = $null
  }
}
