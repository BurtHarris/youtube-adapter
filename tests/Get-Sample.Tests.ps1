BeforeAll {
    $moduleName = 'youtube-adapter'
    $requestedModulePath = $env:YOUTUBE_ADAPTER_TEST_MODULE_PATH
    $builtModule = Join-Path $PSScriptRoot "../output/$moduleName"
    $modulePath = if ($requestedModulePath -and (Test-Path $requestedModulePath)) {
        $requestedModulePath
    }
    elseif (Test-Path $builtModule) {
        $builtModule
    }
    else {
        Join-Path $PSScriptRoot "../src/$moduleName"
    }
    Import-Module $modulePath -Force

    function Resolve-ExportedCmdletName {
        param(
            [Parameter(Mandatory)]
            [string[]]$Candidates
        )

        foreach ($candidate in $Candidates) {
            if (Get-Command -Name $candidate -Module $moduleName -ErrorAction SilentlyContinue) {
                return $candidate
            }
        }

        throw "Could not resolve exported cmdlet from candidates: $($Candidates -join ', ')"
    }

    $script:GetTranscriptEventCommand = Resolve-ExportedCmdletName -Candidates @('Get-TranscriptEvent', 'Get-CopilotTranscriptEvent')
    $script:GetTranscriptFileCommand = Resolve-ExportedCmdletName -Candidates @('Get-TranscriptFile', 'Get-CopilotTranscriptFile')
    $script:GetToolExecutionCommand = Resolve-ExportedCmdletName -Candidates @('Get-ToolExecution', 'Get-CopilotToolExecution')
    $script:GetSessionResourceCommand = Resolve-ExportedCmdletName -Candidates @('Get-SessionResource', 'Get-CopilotSessionResource')
}

Describe 'Get-Sample' {
    It 'greets the given name' {
        Get-Sample -Name 'World' | Should -Be 'Hello, World!'
    }

    It 'accepts pipeline input' {
        'Alice', 'Bob' | Get-Sample | Should -Be @('Hello, Alice!', 'Hello, Bob!')
    }

    It 'rejects an empty name' {
        { Get-Sample -Name '' } | Should -Throw
    }
}

Describe 'Get-TranscriptEvent' {
    It 'reads transcript jsonl events and projects tool metadata' {
        $path = Join-Path $TestDrive 'transcript.jsonl'
        @(
            '{"type":"assistant.message","data":{"sessionId":"session-1","content":"Working","toolRequests":[{"toolCallId":"call-1","name":"read_file","arguments":"{\"filePath\":\"d:\\\\repo\\\\README.md\"}"}]},"id":"msg-1","timestamp":"2026-07-13T09:36:05.016Z","parentId":null}',
            '{"type":"tool.execution_start","data":{"toolCallId":"call-1","toolName":"read_file","arguments":{"filePath":"d:\\repo\\README.md","startLine":1,"endLine":20}},"id":"evt-1","timestamp":"2026-07-13T09:36:05.040Z","parentId":"msg-1"}',
            '{"type":"tool.execution_complete","data":{"toolCallId":"call-1","success":true},"id":"evt-2","timestamp":"2026-07-13T09:36:05.198Z","parentId":"evt-1"}'
        ) | Set-Content -Path $path

        $events = & $script:GetTranscriptEventCommand -Path $path

        $events.Count | Should -Be 3
        $events[0].SessionId | Should -Be 'session-1'
        $events[1].ToolName | Should -Be 'read_file'
        $events[1].ArgumentsJson | Should -Match 'README.md'
        $events[2].Success | Should -BeTrue
    }

    It 'filters transcript events by type' {
        $path = Join-Path $TestDrive 'filtered-transcript.jsonl'
        @(
            '{"type":"assistant.message","data":{"content":"Working"},"id":"msg-1","timestamp":"2026-07-13T09:36:05.016Z","parentId":null}',
            '{"type":"tool.execution_start","data":{"toolCallId":"call-1","toolName":"read_file","arguments":{"filePath":"d:\\repo\\README.md"}},"id":"evt-1","timestamp":"2026-07-13T09:36:05.040Z","parentId":"msg-1"}'
        ) | Set-Content -Path $path

        $events = & $script:GetTranscriptEventCommand -Path $path -Type tool.execution_start

        $events.Count | Should -Be 1
        $events[0].Type | Should -Be 'tool.execution_start'
    }

    It 'reads sid as session id and defaults DataJson when data is missing' {
        $path = Join-Path $TestDrive 'sid-transcript.jsonl'
        @(
            '{"type":"tool.execution_start","id":"evt-1","timestamp":"2026-07-13T09:36:05.040Z","data":{"toolCallId":"call-1","toolName":"read_file","sid":"session-sid"}}',
            '{"type":"assistant.message","id":"evt-2","timestamp":"2026-07-13T09:36:05.050Z"}'
        ) | Set-Content -Path $path

        $events = & $script:GetTranscriptEventCommand -Path $path

        $events.Count | Should -Be 2
        $events[0].SessionId | Should -Be 'session-sid'
        $events[1].DataJson | Should -Be '{}'
    }

    It 'matches type filters case-insensitively' {
        $path = Join-Path $TestDrive 'case-filter-transcript.jsonl'
        @(
            '{"type":"tool.execution_start","data":{"toolCallId":"call-1","toolName":"read_file"},"id":"evt-1","timestamp":"2026-07-13T09:36:05.040Z"}',
            '{"type":"TOOL.EXECUTION_COMPLETE","data":{"toolCallId":"call-1","success":true},"id":"evt-2","timestamp":"2026-07-13T09:36:05.198Z"}'
        ) | Set-Content -Path $path

        $events = & $script:GetTranscriptEventCommand -Path $path -Type tool.execution_complete

        $events.Count | Should -Be 1
        $events[0].Type | Should -Be 'TOOL.EXECUTION_COMPLETE'
    }
}

Describe 'Get-TranscriptFile' {
    It 'discovers transcript files and returns the newest when -Latest is used' {
        $root = Join-Path $TestDrive 'workspaceStorage'
        $transcriptDir = Join-Path $root 'ws-1/GitHub.copilot-chat/transcripts'
        New-Item -Path $transcriptDir -ItemType Directory -Force | Out-Null

        $older = Join-Path $transcriptDir 'session-older.jsonl'
        $newer = Join-Path $transcriptDir 'session-newer.jsonl'
        '{"type":"session.start","data":{}}' | Set-Content -Path $older
        '{"type":"session.start","data":{}}' | Set-Content -Path $newer

        (Get-Item $older).LastWriteTimeUtc = [datetime]::Parse('2026-07-13T09:00:00Z')
        (Get-Item $newer).LastWriteTimeUtc = [datetime]::Parse('2026-07-13T10:00:00Z')

        $all = & $script:GetTranscriptFileCommand -WorkspaceStorageRoot $root
        $latest = & $script:GetTranscriptFileCommand -WorkspaceStorageRoot $root -Latest

        $all.Count | Should -Be 2
        $all[0].SessionId | Should -Be 'session-newer'
        $latest.SessionId | Should -Be 'session-newer'
    }

    It 'filters transcript files by workspace and session wildcard' {
        $root = Join-Path $TestDrive 'workspaceStorage-filters'
        $wsOneDir = Join-Path $root 'ws-1/GitHub.copilot-chat/transcripts'
        $wsTwoDir = Join-Path $root 'ws-2/GitHub.copilot-chat/transcripts'
        New-Item -Path $wsOneDir -ItemType Directory -Force | Out-Null
        New-Item -Path $wsTwoDir -ItemType Directory -Force | Out-Null

        '{}' | Set-Content -Path (Join-Path $wsOneDir 'session-alpha.jsonl')
        '{}' | Set-Content -Path (Join-Path $wsOneDir 'session-beta.jsonl')
        '{}' | Set-Content -Path (Join-Path $wsTwoDir 'session-alpha.jsonl')

        $records = & $script:GetTranscriptFileCommand -WorkspaceStorageRoot $root -WorkspaceId 'ws-1' -SessionId 'session-a*'

        $records.Count | Should -Be 1
        $records[0].WorkspaceId | Should -Be 'ws-1'
        $records[0].SessionId | Should -Be 'session-alpha'
    }
}

Describe 'Get-ToolExecution' {
    It 'projects start and completion events into normalized execution records' {
        $path = Join-Path $TestDrive 'tool-execution.jsonl'
        @(
            '{"type":"tool.execution_start","data":{"toolCallId":"call-1","toolName":"read_file","sessionId":"session-1","arguments":{"filePath":"d:\\repo\\README.md"}},"timestamp":"2026-07-13T09:36:05.040Z"}',
            '{"type":"tool.execution_complete","data":{"toolCallId":"call-1","success":true},"timestamp":"2026-07-13T09:36:05.198Z"}',
            '{"type":"tool.execution_start","data":{"toolCallId":"call-2","toolName":"grep_search","sessionId":"session-1","arguments":{"query":"tool"}},"timestamp":"2026-07-13T09:36:06.000Z"}'
        ) | Set-Content -Path $path

        $records = & $script:GetToolExecutionCommand -Path $path

        $records.Count | Should -Be 2
        $records[0].ToolCallId | Should -Be 'call-1'
        $records[0].Success | Should -BeTrue
        $records[0].DurationMilliseconds | Should -BeGreaterThan 0
        $records[1].ToolCallId | Should -Be 'call-2'
        $records[1].EndTimestamp | Should -BeNullOrEmpty
    }

    It 'filters by tool name' {
        $path = Join-Path $TestDrive 'tool-filter.jsonl'
        @(
            '{"type":"tool.execution_start","data":{"toolCallId":"call-1","toolName":"read_file"},"timestamp":"2026-07-13T09:36:05.040Z"}',
            '{"type":"tool.execution_complete","data":{"toolCallId":"call-1","success":true},"timestamp":"2026-07-13T09:36:05.198Z"}',
            '{"type":"tool.execution_start","data":{"toolCallId":"call-2","toolName":"grep_search"},"timestamp":"2026-07-13T09:36:06.040Z"}'
        ) | Set-Content -Path $path

        $records = & $script:GetToolExecutionCommand -Path $path -ToolName read_file

        $records.Count | Should -Be 1
        $records[0].ToolName | Should -Be 'read_file'
    }

    It 'emits completion-only records when no matching start exists' {
        $path = Join-Path $TestDrive 'orphan-complete.jsonl'
        @(
            '{"type":"tool.execution_complete","data":{"toolCallId":"call-404","sid":"session-sid","success":false},"timestamp":"2026-07-13T09:36:05.198Z"}'
        ) | Set-Content -Path $path

        $records = & $script:GetToolExecutionCommand -Path $path

        $records.Count | Should -Be 1
        $records[0].ToolCallId | Should -Be 'call-404'
        $records[0].SessionId | Should -Be 'session-sid'
        $records[0].StartLineNumber | Should -BeNullOrEmpty
        $records[0].EndLineNumber | Should -Be 1
        $records[0].Success | Should -BeFalse
    }

    It 'ignores malformed json lines and keeps valid execution records' {
        $path = Join-Path $TestDrive 'malformed-lines.jsonl'
        @(
            '{"type":"tool.execution_start","data":{"toolCallId":"call-1","toolName":"read_file"},"timestamp":"2026-07-13T09:36:05.040Z"}',
            '{"type":"this line is malformed"',
            '{"type":"tool.execution_complete","data":{"toolCallId":"call-1","success":true},"timestamp":"2026-07-13T09:36:05.198Z"}'
        ) | Set-Content -Path $path

        $records = & $script:GetToolExecutionCommand -Path $path

        $records.Count | Should -Be 1
        $records[0].ToolCallId | Should -Be 'call-1'
        $records[0].Success | Should -BeTrue
    }
}

Describe 'Get-SessionResource' {
    It 'finds chat-session resource payload folders for a tool call id' {
        $root = Join-Path $TestDrive 'workspaceStorage'
        $resourceDir = Join-Path $root 'ws-1/GitHub.copilot-chat/chat-session-resources/session-1/call_call-1__vscode-1234'
        New-Item -Path $resourceDir -ItemType Directory -Force | Out-Null
        '{}' | Set-Content -Path (Join-Path $resourceDir 'content.json')
        'output' | Set-Content -Path (Join-Path $resourceDir 'content.txt')

        $records = & $script:GetSessionResourceCommand -ToolCallId 'call-1' -WorkspaceStorageRoot $root

        $records.Count | Should -Be 1
        $records[0].SessionId | Should -Be 'session-1'
        $records[0].ContentJsonPath | Should -Match 'content.json'
        $records[0].ContentTextPath | Should -Match 'content.txt'
    }

    It 'filters session resources by workspace and session wildcard and includes schema path' {
        $root = Join-Path $TestDrive 'workspaceStorage-filters'
        $matchResourceDir = Join-Path $root 'ws-1/GitHub.copilot-chat/chat-session-resources/session-1/call_call-123__vscode-1234'
        $otherWorkspaceDir = Join-Path $root 'ws-2/GitHub.copilot-chat/chat-session-resources/session-1/call_call-123__vscode-9999'
        $otherSessionDir = Join-Path $root 'ws-1/GitHub.copilot-chat/chat-session-resources/session-9/call_call-123__vscode-1111'

        New-Item -Path $matchResourceDir -ItemType Directory -Force | Out-Null
        New-Item -Path $otherWorkspaceDir -ItemType Directory -Force | Out-Null
        New-Item -Path $otherSessionDir -ItemType Directory -Force | Out-Null

        '{}' | Set-Content -Path (Join-Path $matchResourceDir 'content.json')
        '{}' | Set-Content -Path (Join-Path $matchResourceDir 'schema.json')

        $records = & $script:GetSessionResourceCommand -ToolCallId 'CALL-123' -WorkspaceStorageRoot $root -WorkspaceId 'ws-1' -SessionId 'session-1'

        $records.Count | Should -Be 1
        $records[0].WorkspaceId | Should -Be 'ws-1'
        $records[0].SessionId | Should -Be 'session-1'
        $records[0].SchemaJsonPath | Should -Match 'schema.json'
    }
}
