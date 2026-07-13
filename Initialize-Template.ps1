<#
    .SYNOPSIS
        Converts this template into your own module project.
    .DESCRIPTION
        Renames SampleModule to your module name across file names, directories,
        and file contents; regenerates the module GUID; updates author metadata;
        and finally deletes itself.
    .EXAMPLE
        ./Initialize-Template.ps1 -ModuleName 'MyAwesomeModule' -Author 'Jane Doe' -Description 'Does awesome things.'
#>
#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z][A-Za-z0-9._-]*$')]
    [string]$ModuleName,

    [Parameter(Mandatory)]
    [string]$Author,

    [Parameter(Mandatory)]
    [string]$Description,

    [string]$GitHubOwner = ''
)

$ErrorActionPreference = 'Stop'
$oldName = 'SampleModule'
$root = $PSScriptRoot

if ($ModuleName -eq $oldName) {
    throw "Choose a module name other than '$oldName'."
}

# Rename directories first (deepest paths unaffected since only src/<name> matches)
$srcDir = Join-Path $root "src/$oldName"
if (Test-Path $srcDir) {
    if ($PSCmdlet.ShouldProcess($srcDir, "Rename to $ModuleName")) {
        Rename-Item -Path $srcDir -NewName $ModuleName
    }
}

# Rename files containing the old name
Get-ChildItem -Path $root -Recurse -File -Filter "*$oldName*" |
    Where-Object FullName -NotMatch '[\\/]\.git[\\/]' |
    ForEach-Object {
        $newFileName = $_.Name -replace [regex]::Escape($oldName), $ModuleName
        if ($PSCmdlet.ShouldProcess($_.FullName, "Rename to $newFileName")) {
            Rename-Item -Path $_.FullName -NewName $newFileName
        }
    }

# Replace content tokens
$textExtensions = '.ps1', '.psm1', '.psd1', '.md', '.yml', '.yaml', '.json'
Get-ChildItem -Path $root -Recurse -File |
    Where-Object { $_.Extension -in $textExtensions -and $_.FullName -notmatch '[\\/]\.git[\\/]' -and $_.Name -ne 'Initialize-Template.ps1' } |
    ForEach-Object {
        $content = Get-Content -Path $_.FullName -Raw
        $updated = $content -replace [regex]::Escape($oldName), $ModuleName
        $updated = $updated -replace 'A sample PowerShell module scaffolded from PSModuleTemplate\.', $Description
        $updated = $updated -replace 'Burt Harris', $Author
        if ($GitHubOwner) {
            $updated = $updated -replace 'BurtHarris/PSModuleTemplate', "$GitHubOwner/$ModuleName"
        }
        if ($updated -ne $content -and $PSCmdlet.ShouldProcess($_.FullName, 'Update content')) {
            Set-Content -Path $_.FullName -Value $updated -Encoding UTF8 -NoNewline
        }
    }

# Fresh GUID for the new module
$manifestPath = Join-Path $root "src/$ModuleName/$ModuleName.psd1"
if ((Test-Path $manifestPath) -and $PSCmdlet.ShouldProcess($manifestPath, 'Regenerate GUID')) {
    Update-ModuleManifest -Path $manifestPath -Guid (New-Guid)
}

if ($PSCmdlet.ShouldProcess('Initialize-Template.ps1', 'Delete self')) {
    Remove-Item -Path (Join-Path $root 'Initialize-Template.ps1')
}

Write-Host "Template initialized as '$ModuleName'. Run ./build.ps1 to verify." -ForegroundColor Green
