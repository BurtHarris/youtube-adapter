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

# Assemble Public/Private functions into a single .psm1 for distribution.
task Build Clean, {
    New-Item -Path $Script:OutputPath -ItemType Directory -Force | Out-Null

    $publicFunctions = @(Get-ChildItem -Path (Join-Path $Script:SourcePath 'Public/*.ps1') -ErrorAction SilentlyContinue)
    $privateFunctions = @(Get-ChildItem -Path (Join-Path $Script:SourcePath 'Private/*.ps1') -ErrorAction SilentlyContinue)

    $builder = [System.Text.StringBuilder]::new()
    foreach ($file in @($privateFunctions + $publicFunctions)) {
        [void]$builder.AppendLine((Get-Content -Path $file.FullName -Raw))
    }
    [void]$builder.AppendLine("Export-ModuleMember -Function @('$($publicFunctions.BaseName -join "', '")')")

    Set-Content -Path (Join-Path $Script:OutputPath "$ModuleName.psm1") -Value $builder.ToString() -Encoding UTF8

    Copy-Item -Path (Join-Path $Script:SourcePath "$ModuleName.psd1") -Destination $Script:OutputPath
    Update-ModuleManifest -Path (Join-Path $Script:OutputPath "$ModuleName.psd1") -FunctionsToExport $publicFunctions.BaseName

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
