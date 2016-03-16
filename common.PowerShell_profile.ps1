#Requires -Version 3

# Would like to get this from $MyInvocation, but haven't found a way to
# make it work right when being dot-sourced
$Global:commonprofile = Join-Path -Path $PSScriptRoot -ChildPath common.PowerShell_profile.ps1


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

function Test-IsAdmin {
<#
.SYNOPSIS
  Tests if script is running with elevated privilege
.NOTES
  This seems to be overkill and possibly problematic way of doing this.
#>

  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal] $identity
  $principal.IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
}

function prompt { 

  if (test-path variable:/PSDebugContext) {
    $isDebug = $true
  }
  $currentDirectory = get-location
  $dirColor = 'Cyan'
  if (Test-IsAdmin) { $dirColor = 'Yellow' }
  if ($isDebug) { $dirColor = 'Magenta' }
  Write-Host '[' -ForegroundColor Gray -NoNewline
  Write-Host "$currentDirectory" -ForegroundColor $dirColor -NoNewline
  Write-Host '] ' -ForegroundColor Gray -NoNewline
  Write-VcsStatus
  Write-Host
  Write-host ':' -ForegroundColor Gray -NoNewline
  return ' '
}

Import-Module posh-git
Start-SshAgent -Quiet
