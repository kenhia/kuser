#Requires -Version 3

function Add-ToEnvPath {
  Param(
  [Parameter(Mandatory=$true)]
  $Path,
  [switch]$Prepend,
  [switch]$Force
  )

  $splitPath = $env:Path.Split(';')
  if ($Prepend -and ($splitPath[0] -ne $Path)) {
    $env:Path = "$Path;$env:Path"
    return
  }
  if ($splitPath.Contains($Path) -and (-not $Force)) {
    return
  }
  $env:Path = "$env:Path;$Path"
}

function Add-GitPath {
  Add-ToEnvPath -Path 'C:\Program Files\Git\bin'
}

function Set-Aliases {
  $aliases = . (Join-Path -Path $PSScriptRoot -ChildPath aliases.ps1)
  foreach ($key in $aliases.Keys) {
    Write-Verbose "Set-Alias -Name $key -Value $($aliases[$key]) -Scope Global"
    Set-Alias -Name $key -Value $aliases[$key] -Scope Global
  }
}
Set-Aliases

function Set-LocationHelper {
  Param($Subdir)

  if ($MyInvocation.InvocationName -eq '..') {
    $tmpPath = '..'
  } else {
    if ($MyInvocation.InvocationName.StartsWith('..')) {
      $argWithoutDotDot = $MyInvocation.InvocationName.Substring(2)
      $levels = 0
      if ([int]::TryParse($argWithoutDotDot, [ref]$levels)) {
        $tmpPath = '..'
        for ($i = 1; $i -lt $levels; $i++) {
          $tmpPath += '\..'
        }
      } else {
        Write-Warning "Don't know how to handle $($MyInvocation.InvocationName)"
      }
    }
  }
  if ($tmpPath) {
    if ($Subdir) {
      $tmpPath = Join-Path -Path $tmpPath -ChildPath $Subdir
    }
    Set-Location $tmpPath
  }
}

