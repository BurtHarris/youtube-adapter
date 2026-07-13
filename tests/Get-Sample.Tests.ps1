BeforeAll {
    $moduleName = 'youtube-adapter'
    $builtModule = Join-Path $PSScriptRoot "../output/$moduleName"
    $modulePath = if (Test-Path $builtModule) { $builtModule } else { Join-Path $PSScriptRoot "../src/$moduleName" }
    Import-Module $modulePath -Force
}

Describe 'Get-Sample' {
    It 'greets the given name' {
        Get-Sample -Name 'World' | Should -Be 'Hello, World!'
    }

    It 'accepts pipeline input' {
        'Alice', 'Bob' | Get-Sample | Should -Be @('Hello, Alice!', 'Hello, Bob!')
    }

    It 'rejects an empty name' {
        { Get-Sample -Name '' } | Should -Throw
    }
}
