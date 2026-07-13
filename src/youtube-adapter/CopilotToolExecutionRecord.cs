namespace YoutubeAdapter;

public sealed class CopilotToolExecutionRecord
{
    public string SourcePath { get; init; } = string.Empty;

    public int? StartLineNumber { get; init; }

    public int? EndLineNumber { get; init; }

    public string? SessionId { get; init; }

    public string? ToolCallId { get; init; }

    public string? ToolName { get; init; }

    public string? ArgumentsJson { get; init; }

    public string? StartTimestamp { get; init; }

    public string? EndTimestamp { get; init; }

    public bool? Success { get; init; }

    public double? DurationMilliseconds { get; init; }
}
