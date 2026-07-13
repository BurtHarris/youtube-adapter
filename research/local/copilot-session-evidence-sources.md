# Copilot Session Evidence Sources

## Question

Which local artifacts reliably expose Copilot session and tool-call history strongly enough to drive deterministic helper generation?

## Decision

Use Copilot transcript JSONL files as the primary evidence source for tool-call mining, with chat-session resource payloads as the secondary source for large tool outputs. Treat `session_store_sql` as a convenience index only when it contains richer data than it does in this environment.

## Findings

### 1. Transcript JSONL is the first authoritative source

Path pattern:

`C:\Users\<user>\AppData\Roaming\Code\User\workspaceStorage\<workspace-id>\GitHub.copilot-chat\transcripts\<session-id>.jsonl`

Observed event types include:

- `session.start`
- `assistant.message`
- `tool.execution_start`
- `tool.execution_complete`
- `assistant.turn_start`
- `assistant.turn_end`
- `user.message`

Key value for this effort:

- `assistant.message` includes `toolRequests` with tool names and serialized arguments.
- `tool.execution_start` includes structured tool arguments for each call.
- `tool.execution_complete` includes per-call success state.
- Event ordering is preserved line-by-line in a simple append-only format.

This is enough to reconstruct a session's tool choreography without relying on a second index.

### 2. Chat-session resources are the secondary source

Path pattern:

`C:\Users\<user>\AppData\Roaming\Code\User\workspaceStorage\<workspace-id>\GitHub.copilot-chat\chat-session-resources\<session-id>\<tool-call-folder>\`

Observed contents include files such as:

- `content.json`
- `content.txt`
- `schema.json`

Key value for this effort:

- Large tool outputs are cached here when they would otherwise be truncated.
- These resources can be joined back to transcript events through the tool call id embedded in the folder name.

This makes chat-session resources the right follow-on source when a transcript event points to a large or structured tool output that needs deeper mining.

### 3. Debug logs are tertiary context, not the primary source

Path pattern:

`C:\Users\<user>\AppData\Roaming\Code\User\workspaceStorage\<workspace-id>\GitHub.copilot-chat\debug-logs\<session-id>\`

Observed files include:

- `main.jsonl`
- `models.json`

In the inspected session, `main.jsonl` only exposed a sparse `session_start` event while `models.json` described model capabilities rather than tool activity. These logs may still help with environment and model context, but they are not the best first source for tool-call mining.

### 4. `session_store_sql` is incomplete in this environment

Observed after reindex:

- `sessions`: populated with a few session headers
- `turns`: empty
- `checkpoints`: empty
- `session_files`: empty
- `session_refs`: empty
- `search_index`: empty

Implication:

- The local SQL index cannot currently serve as the authoritative tool-history source.
- It may still become useful later if future reindex behavior captures transcript content or structured refs.

## Initial module target

The first deterministic-helper module primitives should operate on transcript JSONL directly:

1. Enumerate transcript events.
2. Filter to tool-execution events.
3. Normalize tool arguments into a common shape.
4. Join large-output events to chat-session resource payloads on demand.

That path is the shortest route to a usable mining pipeline.