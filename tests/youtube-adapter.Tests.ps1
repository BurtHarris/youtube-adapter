BeforeDiscovery {
    $script:ModuleName = 'youtube-adapter'
}

BeforeAll {
    $script:ModuleName = 'youtube-adapter'
    $requestedModulePath = $env:YOUTUBE_ADAPTER_TEST_MODULE_PATH
    $builtModule = Join-Path $PSScriptRoot "../output/$script:ModuleName"
    $selectedPath = if ($requestedModulePath -and (Test-Path $requestedModulePath)) {
        $requestedModulePath
    }
    elseif (Test-Path $builtModule) {
        $builtModule
    }
    else {
        Join-Path $PSScriptRoot "../src/$script:ModuleName"
    }

    $isManifestPath = [System.IO.Path]::GetExtension($selectedPath) -eq '.psd1'
    $script:ModuleImportPath = $selectedPath
    $script:ModulePath = if ($isManifestPath) {
        Split-Path -Parent $selectedPath
    }
    else {
        $selectedPath
    }

    Import-Module $script:ModuleImportPath -Force
}

Describe 'Module manifest' {
    BeforeAll {
        $script:Manifest = Test-ModuleManifest -Path (Join-Path $script:ModulePath "$script:ModuleName.psd1")
    }

    It 'has a valid manifest' {
        $script:Manifest | Should -Not -BeNullOrEmpty
    }

    It 'has a valid GUID' {
        $script:Manifest.Guid | Should -Not -Be ([guid]::Empty)
    }

    It 'has a description' {
        $script:Manifest.Description | Should -Not -BeNullOrEmpty
    }

    It 'exports the expected cmdlet surface' {
        $module = Get-Module $script:ModuleName
        $module.ExportedFunctions.Keys | Should -BeNullOrEmpty

        $exportedCmdlets = $module.ExportedCmdlets.Keys
        $exportedCmdlets | Should -Contain 'Get-Sample'
        ($exportedCmdlets | Where-Object { $_ -in @('Get-SessionResource', 'Get-CopilotSessionResource') }).Count | Should -Be 1
        ($exportedCmdlets | Where-Object { $_ -in @('Get-ToolExecution', 'Get-CopilotToolExecution') }).Count | Should -Be 1
        ($exportedCmdlets | Where-Object { $_ -in @('Get-TranscriptEvent', 'Get-CopilotTranscriptEvent') }).Count | Should -Be 1
        ($exportedCmdlets | Where-Object { $_ -in @('Get-TranscriptFile', 'Get-CopilotTranscriptFile') }).Count | Should -Be 1
    }
}

Describe 'Module import' {
    It 'imports without errors' {
        { Import-Module $script:ModulePath -Force -ErrorAction Stop } | Should -Not -Throw
    }

    It 'does not expose private functions' {
        Get-Command -Module $script:ModuleName -Name 'ConvertTo-SampleGreeting' -ErrorAction SilentlyContinue |
            Should -BeNullOrEmpty
    }
}
