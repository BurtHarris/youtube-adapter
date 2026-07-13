# Experiment Record: Phase 2 Efficiency Metrics Baseline

Date: 2026-07-13
Experiment id: 2026-07-13-phase2-efficiency-baseline
Owner: Copilot agent with user guidance
Repo: youtube-adapter

## Hypothesis

If Phase 2 efficiency metrics are captured directly from transcript-derived tool execution records, then experiment reports can include objective timing and execution-efficiency values without adding runtime instrumentation to module code.

## Scope and Change Axis

Primary axis under test:

- guidance change

Out-of-scope controls kept constant:

- module runtime behavior and cmdlet implementations
- transcript source and parsing approach
- test harness and build scripts

## Change Set

Files changed in this experiment:

- research/local/experiments/2026-07-13-phase2-efficiency-baseline.md
- research/local/experiments/2026-07-13-mitigation-value-report-refinement.md

## Human Guidance Inputs

User instructions and inbox references used to shape the change:

- user request: continue till todos are emptied
- prior next experiment candidate in mitigation-value experiment record
- experiment workflow guidance in docs/agents/continuous-improvement.md

## Session Evidence

Primary evidence links:

- Transcript JSONL path: workspaceStorage/.../GitHub.copilot-chat/transcripts/e7f59acf-ecba-4ece-8a79-910acc7c0c47.jsonl
- Relevant tool call ids: transcript-derived aggregate via Get-CopilotToolExecution
- chat-session-resources references: workspaceStorage/.../chat-session-resources/e7f59acf-ecba-4ece-8a79-910acc7c0c47/

## Metrics

### Baseline (Before)

| Metric | Value | Measurement method |
|---|---:|---|
| Phase 2 metrics explicitly recorded in experiment artifacts | 0 | manual review of prior experiment records |
| Session/objective completion time captured | 0 | manual review of prior experiment records |
| Tool call count per completed objective captured | 0 | manual review of prior experiment records |
| Rework proxy captured | 0 | manual review of prior experiment records |

### After

| Metric | Value | Measurement method |
|---|---:|---|
| Phase 2 metrics explicitly recorded in experiment artifacts | 1 | this experiment record includes Phase 2 metrics |
| Session/objective completion time captured | 2550.09 seconds | earliest StartTimestamp to latest EndTimestamp from Get-CopilotToolExecution |
| Tool call count per completed objective captured | 122.00 | total tool calls / 1 completed objective in this experiment scope |
| Rework proxy captured | 15.57% | apply_patch count (19) / total tool calls (122) |

### Delta

| Metric | Before | After | Delta |
|---|---:|---:|---:|
| Phase 2 metrics explicitly recorded in experiment artifacts | 0 | 1 | +1 |
| Session/objective completion time captured | 0 | 2550.09 sec | +2550.09 sec measured |
| Tool call count per completed objective captured | 0 | 122.00 | +122.00 measured |
| Rework proxy captured | 0 | 15.57% | +15.57 pp measured |

## Validity Notes

Threats to validity:

- measurements are from one session and one objective scope
- rework proxy uses apply_patch frequency and may undercount non-patch rework

Potential confounders:

- concurrent edits by user/formatter during the session
- objective boundary defined at session scope, not subtask scope

What was held constant:

- transcript id used for all measurements
- extraction method via Get-CopilotToolExecution
- metric definitions within this experiment

## Decision

Outcome:

- adopt

Decision rationale:

- Phase 2 metrics can be captured now without additional module instrumentation
- metric method is reproducible from transcript evidence
- prior open next-experiment item is now executed

## Next Experiment Candidate

- Completed: see research/local/experiments/2026-07-13-phase3-runtime-performance-baseline.md
