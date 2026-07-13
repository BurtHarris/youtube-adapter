namespace YoutubeAdapter;

public sealed class CopilotSessionResourceRecord
{
    public string WorkspaceStorageRoot { get; init; } = string.Empty;

    public string WorkspaceId { get; init; } = string.Empty;

    public string SessionId { get; init; } = string.Empty;

    public string ToolCallId { get; init; } = string.Empty;

    public string ResourcePath { get; init; } = string.Empty;

    public string? ContentJsonPath { get; init; }

    public string? ContentTextPath { get; init; }

    public string? SchemaJsonPath { get; init; }
}
