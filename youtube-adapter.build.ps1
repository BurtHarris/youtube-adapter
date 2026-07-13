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
    remove (Join-Path $BuildRoot 'output')
}

# Build the compiled cmdlet assembly and package it with the module manifest.
task Build Clean, {
    New-Item -Path $Script:OutputPath -ItemType Directory -Force | Out-Null

    dotnet build (Join-Path $Script:SourcePath "$ModuleName.csproj") --configuration Release --output $Script:OutputPath
    if ($LASTEXITCODE -ne 0) {
        throw 'dotnet build failed.'
    }

    Copy-Item -Path (Join-Path $Script:SourcePath "$ModuleName.psd1") -Destination $Script:OutputPath
    Copy-Item -Path (Join-Path $Script:SourcePath "$ModuleName.psm1") -Destination $Script:OutputPath

    Write-Build Green "Built $ModuleName -> $Script:OutputPath"
}

task Analyze {
    $results = Invoke-ScriptAnalyzer -Path $Script:SourcePath -Recurse -Settings (Join-Path $BuildRoot 'PSScriptAnalyzerSettings.psd1')
    if ($results) {
        $results | Format-Table -AutoSize | Out-String | Write-Build Yellow
        throw "PSScriptAnalyzer found $($results.Count) issue(s)."
    }
}

task Test Build, {
    $configuration = New-PesterConfiguration
    $configuration.Run.Path = Join-Path $BuildRoot 'tests'
    $configuration.Run.Exit = $true
    $configuration.Output.Verbosity = 'Detailed'
    $configuration.TestResult.Enabled = $true
    $configuration.TestResult.OutputPath = Join-Path $BuildRoot 'testResults/results.xml'

    Invoke-Pester -Configuration $configuration
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
