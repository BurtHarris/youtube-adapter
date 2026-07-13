#Requires -Version 5.1
<#
    Bootstrap script: installs build dependencies if missing, then runs Invoke-Build.
    Usage: ./build.ps1            # default task (Analyze + Test)
           ./build.ps1 -Task Build
#>
[CmdletBinding()]
param(
    [string[]]$Task = '.'
)

$ErrorActionPreference = 'Stop'

$dependencies = @(
    @{ Name = 'InvokeBuild'; MinimumVersion = '5.11.0' }
    @{ Name = 'Pester'; MinimumVersion = '5.5.0' }
    @{ Name = 'PSScriptAnalyzer'; MinimumVersion = '1.22.0' }
)

foreach ($dependency in $dependencies) {
    $installed = Get-Module -ListAvailable -Name $dependency.Name |
        Where-Object { $_.Version -ge [version]$dependency.MinimumVersion }
    if (-not $installed) {
        Write-Host "Installing $($dependency.Name) >= $($dependency.MinimumVersion)..."
        Install-Module @dependency -Force -Scope CurrentUser -SkipPublisherCheck -AllowClobber
    }
}

Invoke-Build -Task $Task -File (Join-Path $PSScriptRoot 'youtube-adapter.build.ps1')
