function Get-Sample {
    <#
    .SYNOPSIS
        Returns a greeting for the specified name.
    .DESCRIPTION
        Example public function demonstrating comment-based help, parameter
        validation, and use of a private helper function.
    .PARAMETER Name
        The name to greet.
    .EXAMPLE
        Get-Sample -Name 'World'

        Returns 'Hello, World!'.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    process {
        ConvertTo-SampleGreeting -Name $Name
    }
}
