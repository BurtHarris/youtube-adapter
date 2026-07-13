# Experiment Record: Phase 3 Runtime Performance Baseline

Date: 2026-07-13
Experiment id: 2026-07-13-phase3-runtime-performance-baseline
Owner: Copilot agent with user guidance
Repo: youtube-adapter

## Hypothesis

If key transcript-related cmdlets are benchmarked with repeated runs against a stable transcript input, then we can establish a reproducible Phase 3 runtime-performance baseline suitable for future optimization experiments.

## Scope and Change Axis

Primary axis under test:

- guidance change

Out-of-scope controls kept constant:

- cmdlet implementation code
- transcript input path and workspace storage root
- module manifest export surface

## Change Set

Files changed in this experiment:

- research/local/experiments/2026-07-13-phase3-runtime-performance-baseline.md
- research/local/experiments/2026-07-13-phase2-efficiency-baseline.md

## Human Guidance Inputs

User instructions and inbox references used to shape the change:

- user confirmation to continue after TODO clearing
- continuous-improvement workflow in docs/agents/continuous-improvement.md
- prior suggestion to begin performance metrics baseline

## Session Evidence

Primary evidence links:

- Transcript JSONL path: workspaceStorage/.../GitHub.copilot-chat/transcripts/e7f59acf-ecba-4ece-8a79-910acc7c0c47.jsonl
- Relevant tool call ids: benchmark executed via run_in_terminal and module cmdlet calls
- chat-session-resources references: workspaceStorage/.../chat-session-resources/e7f59acf-ecba-4ece-8a79-910acc7c0c47/

## Metrics

### Baseline (Before)

| Metric | Value | Measurement method |
|---|---:|---|
| Runtime baseline for transcript cmdlets recorded | 0 | manual review of prior experiment artifacts |
| Mean runtime of Get-CopilotToolExecution | 0 ms | no prior runtime benchmark recorded |
| Mean runtime of Get-CopilotTranscriptEvent | 0 ms | no prior runtime benchmark recorded |
| Mean runtime of Get-CopilotTranscriptFile -Latest | 0 ms | no prior runtime benchmark recorded |

### After

| Metric | Value | Measurement method |
|---|---:|---|
| Runtime baseline for transcript cmdlets recorded | 1 | this experiment artifact |
| Mean runtime of Get-CopilotToolExecution | 18.78 ms | 5-run stopwatch benchmark, same transcript input |
| Mean runtime of Get-CopilotTranscriptEvent | 4.52 ms | 5-run stopwatch benchmark, same transcript input |
| Mean runtime of Get-CopilotTranscriptFile -Latest | 3.72 ms | 5-run stopwatch benchmark, same workspace root |

### Delta

| Metric | Before | After | Delta |
|---|---:|---:|---:|
| Runtime baseline for transcript cmdlets recorded | 0 | 1 | +1 |
| Mean runtime of Get-CopilotToolExecution | 0.00 ms | 18.78 ms | +18.78 ms measured |
| Mean runtime of Get-CopilotTranscriptEvent | 0.00 ms | 4.52 ms | +4.52 ms measured |
| Mean runtime of Get-CopilotTranscriptFile -Latest | 0.00 ms | 3.72 ms | +3.72 ms measured |

## Validity Notes

Threats to validity:

- measurements run in one environment and one session state
- first-run and file-cache effects may influence variance (notably max values)

Potential confounders:

- background VS Code activity during timing windows
- DLL lock on output build artifacts prevented parallel build/test duration measurement in this cycle

What was held constant:

- input transcript file
- module import path selection logic
- run count (5) and timing method (Stopwatch)

## Decision

Outcome:

- adopt

Decision rationale:

- Phase 3 runtime baseline now exists and is reproducible
- metrics provide concrete targets for future optimization deltas
- experiment loop remains evidence-linked without changing module behavior

## Next Experiment Candidate

- None
