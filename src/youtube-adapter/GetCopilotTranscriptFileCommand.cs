using System.Management.Automation;

namespace YoutubeAdapter;

[Cmdlet(VerbsCommon.Get, "CopilotTranscriptFile")]
[OutputType(typeof(CopilotTranscriptFileRecord))]
public sealed class GetCopilotTranscriptFileCommand : PSCmdlet
{
    [Parameter]
    [ValidateNotNullOrEmpty]
    public string WorkspaceStorageRoot { get; set; } =
        Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Code", "User", "workspaceStorage");

    [Parameter]
    public string[] WorkspaceId { get; set; } = [];

    [Parameter]
    public string[] SessionId { get; set; } = [];

    [Parameter]
    public SwitchParameter Latest { get; set; }

    protected override void ProcessRecord()
    {
        if (!Directory.Exists(WorkspaceStorageRoot))
        {
            return;
        }

        var matches = new List<CopilotTranscriptFileRecord>();

        foreach (var workspaceDirectory in Directory.EnumerateDirectories(WorkspaceStorageRoot))
        {
            var workspaceId = Path.GetFileName(workspaceDirectory);
            if (!WildcardMatches(WorkspaceId, workspaceId))
            {
                continue;
            }

            var transcriptDirectory = Path.Combine(workspaceDirectory, "GitHub.copilot-chat", "transcripts");
            if (!Directory.Exists(transcriptDirectory))
            {
                continue;
            }

            foreach (var transcriptPath in Directory.EnumerateFiles(transcriptDirectory, "*.jsonl"))
            {
                var sessionId = Path.GetFileNameWithoutExtension(transcriptPath);
                if (!WildcardMatches(SessionId, sessionId))
                {
                    continue;
                }

                var fileInfo = new FileInfo(transcriptPath);
                matches.Add(new CopilotTranscriptFileRecord
                {
                    WorkspaceStorageRoot = WorkspaceStorageRoot,
                    WorkspaceId = workspaceId,
                    SessionId = sessionId,
                    FullPath = transcriptPath,
                    LastWriteTimeUtc = fileInfo.LastWriteTimeUtc,
                    Length = fileInfo.Length
                });
            }
        }

        var ordered = matches
            .OrderByDescending(item => item.LastWriteTimeUtc)
            .ThenBy(item => item.SessionId, StringComparer.OrdinalIgnoreCase)
            .ToList();

        if (Latest)
        {
            var latest = ordered.FirstOrDefault();
            if (latest is not null)
            {
                WriteObject(latest);
            }

            return;
        }

        WriteObject(ordered, enumerateCollection: true);
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
