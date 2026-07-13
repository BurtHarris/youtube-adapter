# Thin script root so the manifest can remain stable while the implementation
# moves to a compiled cmdlet assembly.
$assemblyCandidates = @(
    (Join-Path $PSScriptRoot 'youtube-adapter.dll'),
    (Join-Path $PSScriptRoot 'bin/Release/net8.0/youtube-adapter.dll'),
    (Join-Path $PSScriptRoot 'bin/Debug/net8.0/youtube-adapter.dll')
)

$assemblyPath = $assemblyCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $assemblyPath) {
    throw "Could not find youtube-adapter.dll. Build the C# project first."
}

Import-Module -Name $assemblyPath
