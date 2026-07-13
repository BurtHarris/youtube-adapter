#Requires -Version 7.4
[CmdletBinding()]
param(
    [switch]$SkipDependencyInstall
)

$ErrorActionPreference = 'Stop'

$script:RepoRoot = Split-Path -Parent $PSCommandPath
$script:ModuleName = 'youtube-adapter'

function Get-BestBuiltModulePath {
    $outputRoot = Join-Path $script:RepoRoot 'output'
    if (-not (Test-Path $outputRoot)) {
        return $null
    }

    $candidates = Get-ChildItem -Path $outputRoot -Directory |
        Where-Object {
            $_.Name -eq $script:ModuleName -or $_.Name -like "$script:ModuleName-staged-*"
        } |
        Sort-Object LastWriteTimeUtc -Descending

    foreach ($candidate in $candidates) {
        $manifestPath = Join-Path $candidate.FullName "$script:ModuleName.psd1"
        if (Test-Path $manifestPath) {
            return $candidate.FullName
        }
    }

    return $null
}

function Initialize-ProjectDependencies {
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
}

function Invoke-ProjectTask {
    [CmdletBinding()]
    param(
        [string[]]$Task = '.'
    )

    & (Join-Path $script:RepoRoot 'build.ps1') -Task $Task
}

function Invoke-ProjectBuild {
    [CmdletBinding()]
    param()

    Invoke-ProjectTask -Task Build
}

function Invoke-ProjectAnalyze {
    [CmdletBinding()]
    param()

    Invoke-ProjectTask -Task Analyze
}

function Invoke-ProjectTests {
    [CmdletBinding()]
    param()

    Invoke-ProjectTask -Task Test
}

function Import-ProjectModule {
    [CmdletBinding()]
    param()

    $moduleToRemove = Get-Module -Name $script:ModuleName -ErrorAction SilentlyContinue
    if ($moduleToRemove) {
        Remove-Module -Name $script:ModuleName -Force
    }

    Import-Module $env:YOUTUBE_ADAPTER_TEST_MODULE_PATH -Force
}

Set-Location $script:RepoRoot

if (-not $SkipDependencyInstall) {
    Initialize-ProjectDependencies
}

$builtModulePath = Get-BestBuiltModulePath
if (-not $builtModulePath) {
    Invoke-ProjectBuild
    $builtModulePath = Get-BestBuiltModulePath
}

if (-not $builtModulePath) {
    throw "Could not resolve a built module path under output/. Run './build.ps1 -Task Build' and retry."
}

$builtModuleManifestPath = Join-Path $builtModulePath "$script:ModuleName.psd1"
if (-not (Test-Path $builtModuleManifestPath)) {
    throw "Could not find module manifest at '$builtModuleManifestPath'."
}

$env:YOUTUBE_ADAPTER_TEST_MODULE_PATH = $builtModuleManifestPath

Write-Host "Dev shell ready at $script:RepoRoot"
Write-Host "Module path: $builtModulePath"
Write-Host "Test override: YOUTUBE_ADAPTER_TEST_MODULE_PATH=$env:YOUTUBE_ADAPTER_TEST_MODULE_PATH"
Write-Host "Commands: Invoke-ProjectBuild, Invoke-ProjectAnalyze, Invoke-ProjectTests, Import-ProjectModule"
