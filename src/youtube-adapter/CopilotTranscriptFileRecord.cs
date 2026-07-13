namespace YoutubeAdapter;

public sealed class CopilotTranscriptFileRecord
{
    public string WorkspaceStorageRoot { get; init; } = string.Empty;

    public string WorkspaceId { get; init; } = string.Empty;

    public string SessionId { get; init; } = string.Empty;

    public string FullPath { get; init; } = string.Empty;

    public DateTime LastWriteTimeUtc { get; init; }

    public long Length { get; init; }
}
