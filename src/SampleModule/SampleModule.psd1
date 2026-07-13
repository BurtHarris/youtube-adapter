@{
    RootModule        = 'SampleModule.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '6c31d1de-3b46-4c9f-8a55-1c2f0f7d9e01'
    Author            = 'Burt Harris'
    Description       = 'A sample PowerShell module scaffolded from PSModuleTemplate.'
    PowerShellVersion = '5.1'

    FunctionsToExport = @('Get-Sample')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData       = @{
        PSData = @{
            Tags         = @('template', 'sample')
            LicenseUri   = 'https://github.com/BurtHarris/PSModuleTemplate/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/BurtHarris/PSModuleTemplate'
            ReleaseNotes = 'Initial release.'
        }
    }
}
