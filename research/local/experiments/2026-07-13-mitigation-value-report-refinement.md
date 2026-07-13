# Experiment Record: Mitigation-Value Report Refinement

Date: 2026-07-13
Experiment id: 2026-07-13-mitigation-values
Owner: Copilot agent with user guidance
Repo: youtube-adapter

## Hypothesis

If the compliance report replaces qualitative compliance wording with explicit before/after mitigation values and deltas, then traceability and decision usefulness will improve measurably without requiring advanced performance instrumentation.

## Scope and Change Axis

Primary axis under test:

- guidance change

Out-of-scope controls kept constant:

- module code and runtime behavior
- build and test tooling
- metric extraction source (module manifest and report text)

## Change Set

Files changed in this experiment:

- research/local/powershell-guideline-compliance-report-2026-07-13.md
- docs/agents/continuous-improvement.md
- research/local/refinement-as-scientific-experiment-program.md
- AGENTS.md

## Human Guidance Inputs

User instructions and inbox references used to shape the change:

- user requested scientific experiment framing tied to session records and guidance/spec changes
- user requested before/after mitigation values in the compliance report
- inbox-first policy from AGENTS and repo instructions

## Session Evidence

Primary evidence links:

- Transcript JSONL path: c:/Users/Burt/AppData/Roaming/Code/User/workspaceStorage/0fdcf7ddf0de496986c19bbd4ce83cdf/GitHub.copilot-chat/transcripts/e7f59acf-ecba-4ece-8a79-910acc7c0c47.jsonl
- Relevant tool call ids: call_8YMcrAKVHLGPGtBk0ljRETH6__vscode-1783932888703
- chat-session-resources references: workspaceStorage/.../chat-session-resources/e7f59acf-ecba-4ece-8a79-910acc7c0c47/

## Metrics

### Baseline (Before)

| Metric | Value | Measurement method |
|---|---:|---|
| Mitigation-value table present | 0 | manual section check in compliance report |
| Guideline areas with explicit before and after mitigation values | 0 | count rows containing before+after mitigation values |
| Ambiguous range values in comparison table | 2 | count range-form entries (0-5, 0-100%) |
| Decode requirement phrasing strictness | 1 strict statement | manual wording review |

### After

| Metric | Value | Measurement method |
|---|---:|---|
| Mitigation-value table present | 1 | manual section check in compliance report |
| Guideline areas with explicit before and after mitigation values | 4 | count rows in mitigation value table |
| Ambiguous range values in comparison table | 0 | count range-form entries |
| Decode requirement phrasing strictness | 0 strict statements | manual wording review |

### Delta

| Metric | Before | After | Delta |
|---|---:|---:|---:|
| Mitigation-value table present | 0 | 1 | +1 |
| Guideline areas with explicit before and after mitigation values | 0 | 4 | +4 |
| Ambiguous range values in comparison table | 2 | 0 | -2 |
| Decode requirement phrasing strictness | 1 | 0 | -1 |

## Validity Notes

Threats to validity:

- metrics are document-structure metrics, not runtime or productivity metrics
- one-session sample size limits generalization

Potential confounders:

- concurrent edits by user or formatter during the same session
- interpretation variance for ordinal mitigation scoring

What was held constant:

- repository scope (youtube-adapter)
- baseline source report file
- measurement framing (before/after with explicit deltas)

## Decision

Outcome:

- adopt

Decision rationale:

- report now supports explicit before/after mitigation analysis
- guidance now codifies repeatable experiment workflow
- evidence linkage is captured and reproducible for future cycles

## Next Experiment Candidate

- Completed: see research/local/experiments/2026-07-13-phase2-efficiency-baseline.md
