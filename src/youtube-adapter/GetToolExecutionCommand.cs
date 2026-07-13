using System.Management.Automation;
using System.Text.Json;

namespace YoutubeAdapter;

[Cmdlet(VerbsCommon.Get, "ToolExecution")]
[OutputType(typeof(CopilotToolExecutionRecord))]
public sealed class GetToolExecutionCommand : PSCmdlet
{
    [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true)]
    [Alias("FullName")]
    [ValidateNotNullOrEmpty]
    public string[] Path { get; set; } = [];

    [Parameter]
    public string[] ToolName { get; set; } = [];

    protected override void ProcessRecord()
    {
        foreach (var inputPath in Path)
        {
            foreach (var resolvedPath in GetResolvedProviderPathFromPSPath(inputPath, out _))
            {
                EmitExecutions(resolvedPath);
            }
        }
    }

    private void EmitExecutions(string path)
    {
        var pendingStarts = new Dictionary<string, PendingStart>(StringComparer.OrdinalIgnoreCase);
        var lineNumber = 0;

        foreach (var line in File.ReadLines(path))
        {
            lineNumber++;
            if (string.IsNullOrWhiteSpace(line))
            {
                continue;
            }

            JsonDocument document;
            try
            {
                document = JsonDocument.Parse(line);
            }
            catch (JsonException)
            {
                continue;
            }

            using (document)
            {
                var root = document.RootElement;
                var eventType = TryGetString(root, "type");
                if (string.IsNullOrEmpty(eventType))
                {
                    continue;
                }

                root.TryGetProperty("data", out var data);

                if (string.Equals(eventType, "tool.execution_start", StringComparison.OrdinalIgnoreCase))
                {
                    var toolName = TryGetString(data, "toolName");
                    if (!ToolNameMatches(toolName))
                    {
                        continue;
                    }

                    var toolCallId = TryGetString(data, "toolCallId");
                    if (string.IsNullOrEmpty(toolCallId))
                    {
                        continue;
                    }

                    pendingStarts[toolCallId] = new PendingStart
                    {
                        SourcePath = path,
                        StartLineNumber = lineNumber,
                        SessionId = TryGetSessionId(data),
                        ToolCallId = toolCallId,
                        ToolName = toolName,
                        ArgumentsJson = TryGetArgumentsJson(data),
                        StartTimestamp = TryGetString(root, "timestamp")
                    };

                    continue;
                }

                if (!string.Equals(eventType, "tool.execution_complete", StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                var completeToolCallId = TryGetString(data, "toolCallId");
                if (string.IsNullOrEmpty(completeToolCallId))
                {
                    continue;
                }

                var endTimestamp = TryGetString(root, "timestamp");
                var success = TryGetBoolean(data, "success");

                if (pendingStarts.Remove(completeToolCallId, out var pending))
                {
                    WriteObject(new CopilotToolExecutionRecord
                    {
                        SourcePath = pending.SourcePath,
                        StartLineNumber = pending.StartLineNumber,
                        EndLineNumber = lineNumber,
                        SessionId = pending.SessionId,
                        ToolCallId = pending.ToolCallId,
                        ToolName = pending.ToolName,
                        ArgumentsJson = pending.ArgumentsJson,
                        StartTimestamp = pending.StartTimestamp,
                        EndTimestamp = endTimestamp,
                        Success = success,
                        DurationMilliseconds = ComputeDurationMilliseconds(pending.StartTimestamp, endTimestamp)
                    });

                    continue;
                }

                if (ToolName.Length == 0)
                {
                    WriteObject(new CopilotToolExecutionRecord
                    {
                        SourcePath = path,
                        EndLineNumber = lineNumber,
                        SessionId = TryGetSessionId(data),
                        ToolCallId = completeToolCallId,
                        EndTimestamp = endTimestamp,
                        Success = success
                    });
                }
            }
        }

        foreach (var pending in pendingStarts.Values.OrderBy(item => item.StartLineNumber))
        {
            WriteObject(new CopilotToolExecutionRecord
            {
                SourcePath = pending.SourcePath,
                StartLineNumber = pending.StartLineNumber,
                SessionId = pending.SessionId,
                ToolCallId = pending.ToolCallId,
                ToolName = pending.ToolName,
                ArgumentsJson = pending.ArgumentsJson,
                StartTimestamp = pending.StartTimestamp
            });
        }
    }

    private bool ToolNameMatches(string? candidate)
    {
        if (ToolName.Length == 0)
        {
            return true;
        }

        if (string.IsNullOrEmpty(candidate))
        {
            return false;
        }

        return ToolName.Any(filter => string.Equals(filter, candidate, StringComparison.OrdinalIgnoreCase));
    }

    private static double? ComputeDurationMilliseconds(string? startTimestamp, string? endTimestamp)
    {
        if (DateTimeOffset.TryParse(startTimestamp, out var start) && DateTimeOffset.TryParse(endTimestamp, out var end))
        {
            return (end - start).TotalMilliseconds;
        }

        return null;
    }

    private static string? TryGetSessionId(JsonElement element)
    {
        var sessionId = TryGetString(element, "sessionId");
        if (!string.IsNullOrEmpty(sessionId))
        {
            return sessionId;
        }

        return TryGetString(element, "sid");
    }

    private static string? TryGetArgumentsJson(JsonElement element)
    {
        if (element.ValueKind == JsonValueKind.Undefined || !element.TryGetProperty("arguments", out var arguments))
        {
            return null;
        }

        return arguments.ValueKind == JsonValueKind.String
            ? arguments.GetString()
            : arguments.GetRawText();
    }

    private static bool? TryGetBoolean(JsonElement element, string propertyName)
    {
        if (element.ValueKind == JsonValueKind.Undefined || !element.TryGetProperty(propertyName, out var value))
        {
            return null;
        }

        return value.ValueKind switch
        {
            JsonValueKind.True => true,
            JsonValueKind.False => false,
            _ => null
        };
    }

    private static string? TryGetString(JsonElement element, string propertyName)
    {
        if (element.ValueKind == JsonValueKind.Undefined || !element.TryGetProperty(propertyName, out var value))
        {
            return null;
        }

        return value.ValueKind == JsonValueKind.String
            ? value.GetString()
            : value.GetRawText();
    }

    private sealed class PendingStart
    {
        public string SourcePath { get; init; } = string.Empty;

        public int StartLineNumber { get; init; }

        public string? SessionId { get; init; }

        public string ToolCallId { get; init; } = string.Empty;

        public string? ToolName { get; init; }

        public string? ArgumentsJson { get; init; }

        public string? StartTimestamp { get; init; }
    }
}