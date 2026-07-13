<#
    Invoke-Build script. Run via ./build.ps1 or directly with Invoke-Build.
    Tasks: Clean, Build, Analyze, Test, Docs, . (default: Analyze + Test)
#>
param(
    [string]$ModuleName = 'youtube-adapter'
)

$Script:SourcePath = Join-Path $BuildRoot "src/$ModuleName"
$Script:OutputPath = Join-Path $BuildRoot "output/$ModuleName"

task Clean {
    $outputPath = Join-Path $BuildRoot 'output'
    if (-not (Test-Path $outputPath)) {
        return
    }

    try {
        Remove-Item -Path $outputPath -Recurse -Force -ErrorAction Stop
    }
    catch {
        Write-Build Yellow "Skipping clean for '$outputPath' because it is in use: $($_.Exception.Message)"
    }
}

# Build the compiled cmdlet assembly and package it with the module manifest.
task Build Clean, {
    $targetOutputPath = $Script:OutputPath
    $targetDllPath = Join-Path $targetOutputPath "$ModuleName.dll"

    if (Test-Path $targetDllPath) {
        $isLocked = $false
        try {
            $stream = [System.IO.File]::Open($targetDllPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
            $stream.Dispose()
        }
        catch {
            $isLocked = $true
        }

        if ($isLocked) {
            $targetOutputPath = Join-Path $BuildRoot ("output/{0}-staged-{1}" -f $ModuleName, (Get-Date -Format 'yyyyMMddHHmmss'))
            Write-Build Yellow "Primary output is locked; building to staged path '$targetOutputPath'."
        }
    }

    New-Item -Path $targetOutputPath -ItemType Directory -Force | Out-Null

    dotnet build (Join-Path $Script:SourcePath "$ModuleName.csproj") --configuration Release --output $targetOutputPath
    if ($LASTEXITCODE -ne 0) {
        throw 'dotnet build failed.'
    }

    Copy-Item -Path (Join-Path $Script:SourcePath "$ModuleName.psd1") -Destination $targetOutputPath
    Copy-Item -Path (Join-Path $Script:SourcePath "$ModuleName.psm1") -Destination $targetOutputPath

    $Script:OutputPath = $targetOutputPath

    Write-Build Green "Built $ModuleName -> $Script:OutputPath"
}

task Analyze {
    $analysisPaths = @(
        Get-ChildItem -Path $Script:SourcePath -Recurse -File -Include '*.ps1', '*.psm1' |
            Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' } |
            Select-Object -ExpandProperty FullName
    )

    if ($analysisPaths.Count -eq 0) {
        Write-Build Yellow 'No PowerShell files found for analysis.'
        return
    }

    $settingsPath = Join-Path $BuildRoot 'PSScriptAnalyzerSettings.psd1'
    $results = foreach ($analysisPath in $analysisPaths) {
        Invoke-ScriptAnalyzer -Path $analysisPath -Settings $settingsPath
    }

    if ($results) {
        $results | Format-Table -AutoSize | Out-String | Write-Build Yellow
        throw "PSScriptAnalyzer found $($results.Count) issue(s)."
    }
}

task Test {
    $testModulePath = Join-Path ([System.IO.Path]::GetTempPath()) "youtube-adapter-test/$([guid]::NewGuid())/$ModuleName"
    New-Item -Path $testModulePath -ItemType Directory -Force | Out-Null

    dotnet build (Join-Path $Script:SourcePath "$ModuleName.csproj") --configuration Release --output $testModulePath
    if ($LASTEXITCODE -ne 0) {
        throw 'dotnet build failed for test module path.'
    }

    Copy-Item -Path (Join-Path $Script:SourcePath "$ModuleName.psd1") -Destination $testModulePath
    Copy-Item -Path (Join-Path $Script:SourcePath "$ModuleName.psm1") -Destination $testModulePath

    $testModuleManifestPath = Join-Path $testModulePath "$ModuleName.psd1"
    $previousModulePath = $env:YOUTUBE_ADAPTER_TEST_MODULE_PATH
    $env:YOUTUBE_ADAPTER_TEST_MODULE_PATH = $testModuleManifestPath

    $configuration = New-PesterConfiguration
    $configuration.Run.Path = Join-Path $BuildRoot 'tests'
    $configuration.Run.Exit = $true
    $configuration.Output.Verbosity = 'Detailed'
    $configuration.TestResult.Enabled = $true
    $configuration.TestResult.OutputPath = Join-Path $BuildRoot 'testResults/results.xml'

    try {
        Invoke-Pester -Configuration $configuration
    }
    finally {
        if ($null -ne $previousModulePath) {
            $env:YOUTUBE_ADAPTER_TEST_MODULE_PATH = $previousModulePath
        }
        else {
            Remove-Item Env:YOUTUBE_ADAPTER_TEST_MODULE_PATH -ErrorAction SilentlyContinue
        }
    }
}

# Requires platyPS (optional): Install-Module platyPS
task Docs Build, {
    if (-not (Get-Module -ListAvailable -Name platyPS)) {
        Write-Build Yellow 'platyPS not installed; skipping docs generation.'
        return
    }
    Import-Module $Script:OutputPath -Force
    New-MarkdownHelp -Module $ModuleName -OutputFolder (Join-Path $BuildRoot 'docs') -Force | Out-Null
    Write-Build Green 'Docs generated in ./docs'
}

task . Analyze, Test
