using System.Management.Automation;
using System.Text.Json;

namespace YoutubeAdapter;

[Cmdlet(VerbsCommon.Get, "TranscriptEvent")]
[OutputType(typeof(CopilotTranscriptEvent))]
public sealed class GetTranscriptEventCommand : PSCmdlet
{
    [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true)]
    [Alias("FullName")]
    [ValidateNotNullOrEmpty]
    public string[] Path { get; set; } = [];

    [Parameter]
    public string[] Type { get; set; } = [];

    protected override void ProcessRecord()
    {
        foreach (var inputPath in Path)
        {
            foreach (var resolvedPath in GetResolvedProviderPathFromPSPath(inputPath, out _))
            {
                EmitEvents(resolvedPath);
            }
        }
    }

    private void EmitEvents(string path)
    {
        var lineNumber = 0;

        foreach (var line in File.ReadLines(path))
        {
            lineNumber++;
            if (string.IsNullOrWhiteSpace(line))
            {
                continue;
            }

            using var document = JsonDocument.Parse(line);
            var root = document.RootElement;
            var eventType = TryGetString(root, "type");
            if (string.IsNullOrEmpty(eventType))
            {
                continue;
            }

            if (Type.Length > 0 && !Type.Any(filter => string.Equals(filter, eventType, StringComparison.OrdinalIgnoreCase)))
            {
                continue;
            }

            root.TryGetProperty("data", out var data);

            WriteObject(new CopilotTranscriptEvent
            {
                SourcePath = path,
                LineNumber = lineNumber,
                Type = eventType,
                Id = TryGetString(root, "id"),
                ParentId = TryGetString(root, "parentId"),
                Timestamp = TryGetString(root, "timestamp"),
                SessionId = TryGetSessionId(data),
                ToolCallId = TryGetString(data, "toolCallId"),
                ToolName = TryGetString(data, "toolName"),
                Content = TryGetString(data, "content"),
                ArgumentsJson = TryGetArgumentsJson(data),
                Success = TryGetBoolean(data, "success"),
                DataJson = data.ValueKind == JsonValueKind.Undefined ? "{}" : data.GetRawText()
            });
        }
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
}