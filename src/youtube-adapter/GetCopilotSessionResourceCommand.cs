using System.Management.Automation;

namespace YoutubeAdapter;

[Cmdlet(VerbsCommon.Get, "CopilotSessionResource")]
[OutputType(typeof(CopilotSessionResourceRecord))]
public sealed class GetCopilotSessionResourceCommand : PSCmdlet
{
    [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
    [ValidateNotNullOrEmpty]
    public string[] ToolCallId { get; set; } = [];

    [Parameter]
    [ValidateNotNullOrEmpty]
    public string WorkspaceStorageRoot { get; set; } =
        Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Code", "User", "workspaceStorage");

    [Parameter]
    public string[] WorkspaceId { get; set; } = [];

    [Parameter]
    public string[] SessionId { get; set; } = [];

    protected override void ProcessRecord()
    {
        if (!Directory.Exists(WorkspaceStorageRoot))
        {
            return;
        }

        foreach (var requestedToolCallId in ToolCallId)
        {
            EmitMatchesForToolCall(requestedToolCallId);
        }
    }

    private void EmitMatchesForToolCall(string requestedToolCallId)
    {
        foreach (var workspaceDirectory in Directory.EnumerateDirectories(WorkspaceStorageRoot))
        {
            var workspaceId = Path.GetFileName(workspaceDirectory);
            if (!WildcardMatches(WorkspaceId, workspaceId))
            {
                continue;
            }

            var sessionsRoot = Path.Combine(workspaceDirectory, "GitHub.copilot-chat", "chat-session-resources");
            if (!Directory.Exists(sessionsRoot))
            {
                continue;
            }

            foreach (var sessionDirectory in Directory.EnumerateDirectories(sessionsRoot))
            {
                var sessionId = Path.GetFileName(sessionDirectory);
                if (!WildcardMatches(SessionId, sessionId))
                {
                    continue;
                }

                foreach (var resourceDirectory in Directory.EnumerateDirectories(sessionDirectory))
                {
                    var resourceName = Path.GetFileName(resourceDirectory);
                    if (resourceName.IndexOf(requestedToolCallId, StringComparison.OrdinalIgnoreCase) < 0)
                    {
                        continue;
                    }

                    var contentJsonPath = Path.Combine(resourceDirectory, "content.json");
                    var contentTextPath = Path.Combine(resourceDirectory, "content.txt");
                    var schemaJsonPath = Path.Combine(resourceDirectory, "schema.json");

                    WriteObject(new CopilotSessionResourceRecord
                    {
                        WorkspaceStorageRoot = WorkspaceStorageRoot,
                        WorkspaceId = workspaceId,
                        SessionId = sessionId,
                        ToolCallId = requestedToolCallId,
                        ResourcePath = resourceDirectory,
                        ContentJsonPath = File.Exists(contentJsonPath) ? contentJsonPath : null,
                        ContentTextPath = File.Exists(contentTextPath) ? contentTextPath : null,
                        SchemaJsonPath = File.Exists(schemaJsonPath) ? schemaJsonPath : null
                    });
                }
            }
        }
    }

    private static bool WildcardMatches(string[] filters, string candidate)
    {
        if (filters.Length == 0)
        {
            return true;
        }

        return filters.Any(filter => WildcardPattern.Get(filter, WildcardOptions.IgnoreCase).IsMatch(candidate));
    }
}
