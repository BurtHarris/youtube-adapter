BeforeDiscovery {
    $script:ModuleName = 'SampleModule'
}

BeforeAll {
    $script:ModuleName = 'SampleModule'
    $builtModule = Join-Path $PSScriptRoot "../output/$script:ModuleName"
    $script:ModulePath = if (Test-Path $builtModule) { $builtModule } else { Join-Path $PSScriptRoot "../src/$script:ModuleName" }
    Import-Module $script:ModulePath -Force
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

    It 'exports only public functions' {
        $publicFiles = Get-ChildItem -Path (Join-Path $PSScriptRoot "../src/$script:ModuleName/Public/*.ps1")
        $exported = (Get-Module $script:ModuleName).ExportedFunctions.Keys
        $exported | Sort-Object | Should -Be ($publicFiles.BaseName | Sort-Object)
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
