function ConvertTo-SampleGreeting {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    "Hello, $Name!"
}
