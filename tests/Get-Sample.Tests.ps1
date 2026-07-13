BeforeAll {
    $moduleName = 'youtube-adapter'
    $builtModule = Join-Path $PSScriptRoot "../output/$moduleName"
    $modulePath = if (Test-Path $builtModule) { $builtModule } else { Join-Path $PSScriptRoot "../src/$moduleName" }
    Import-Module $modulePath -Force
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

Describe 'Get-CopilotTranscriptEvent' {
    It 'reads transcript jsonl events and projects tool metadata' {
        $path = Join-Path $TestDrive 'transcript.jsonl'
        @(
            '{"type":"assistant.message","data":{"sessionId":"session-1","content":"Working","toolRequests":[{"toolCallId":"call-1","name":"read_file","arguments":"{\"filePath\":\"d:\\\\repo\\\\README.md\"}"}]},"id":"msg-1","timestamp":"2026-07-13T09:36:05.016Z","parentId":null}',
            '{"type":"tool.execution_start","data":{"toolCallId":"call-1","toolName":"read_file","arguments":{"filePath":"d:\\repo\\README.md","startLine":1,"endLine":20}},"id":"evt-1","timestamp":"2026-07-13T09:36:05.040Z","parentId":"msg-1"}',
            '{"type":"tool.execution_complete","data":{"toolCallId":"call-1","success":true},"id":"evt-2","timestamp":"2026-07-13T09:36:05.198Z","parentId":"evt-1"}'
        ) | Set-Content -Path $path

        $events = Get-CopilotTranscriptEvent -Path $path

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

        $events = Get-CopilotTranscriptEvent -Path $path -Type tool.execution_start

        $events.Count | Should -Be 1
        $events[0].Type | Should -Be 'tool.execution_start'
    }
}
