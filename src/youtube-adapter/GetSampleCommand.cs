using System.Management.Automation;

namespace YoutubeAdapter;

[Cmdlet(VerbsCommon.Get, "Sample")]
[OutputType(typeof(string))]
public sealed class GetSampleCommand : PSCmdlet
{
    [Parameter(Mandatory = true, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string Name { get; set; } = string.Empty;

    protected override void ProcessRecord()
    {
        WriteObject($"Hello, {Name}!");
    }
}
