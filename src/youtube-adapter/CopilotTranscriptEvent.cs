namespace YoutubeAdapter;

public sealed class CopilotTranscriptEvent
{
    public string SourcePath { get; init; } = string.Empty;

    public int LineNumber { get; init; }

    public string Type { get; init; } = string.Empty;

    public string? Id { get; init; }

    public string? ParentId { get; init; }

    public string? Timestamp { get; init; }

    public string? SessionId { get; init; }

    public string? ToolCallId { get; init; }

    public string? ToolName { get; init; }

    public string? Content { get; init; }

    public string? ArgumentsJson { get; init; }

    public bool? Success { get; init; }

    public string DataJson { get; init; } = "{}";
}