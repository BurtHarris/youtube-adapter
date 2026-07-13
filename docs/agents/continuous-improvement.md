# Continuous Improvement Experiments

Use this guide when refining prompts, specs, cmdlet naming, workflow conventions, or implementation strategy.

Goal: treat refinement as a scientific program with reproducible evidence, measurable outcomes, and traceability to session history, specification edits, and human guidance.

## External knowledge inbox

Before designing non-trivial experiments, consult d:/inbox for relevant user-provided knowledge.
Use applicable inbox context as input assumptions for hypotheses and success criteria.

## Autopilot execution cadence

When executing a todo list in autopilot mode:
- Pause for about 10 seconds between todo items to allow user interruption.
- If the user interrupts, stop and re-align before continuing.
- If no interruption occurs, continue automatically with the next todo item.
- When a ticket is resolved and closed, create a checkpoint commit and compact context before retrieving the next ticket.

## Evidence hierarchy

Use this order of trust for Copilot-session evidence:

1. Transcript JSONL records in workspaceStorage.
2. chat-session-resources payloads keyed by tool call id.
3. Debug logs as tertiary context only.

If evidence from lower-priority sources conflicts with higher-priority sources, prefer the higher-priority source and note the conflict.

### Source priority and fallback protocol

Use this compact order when collecting session-history evidence for experiments:

1. Query built-in Chronicle-style outputs or local SQL session indexes first for quick aggregates and trend checks.
2. If SQL/index coverage is sparse (for example, sessions exist but turns/refs are empty), fall back to transcript JSONL as the authoritative source.
3. Use chat-session-resources payloads as structured supplements for large tool outputs.
4. Use debug logs only for tertiary context or gap-filling.

Operational rule:

- Cross-validate summary metrics from SQL/Chronicle against transcript-derived counts before publishing conclusions.
- In every experiment report, record which source supplied each metric and why any fallback was used.

## Scientific loop

Use a compact PDCA loop aligned to coding workflow:

1. Plan:
- Define one change under test (for example, naming policy, alias policy, or prompt guidance).
- Define a falsifiable hypothesis and target metrics.
- Capture baseline metrics before any change.

2. Do:
- Apply the smallest viable change set.
- Record exact spec and guidance edits with file paths.

3. Check:
- Re-measure metrics using the same method as baseline.
- Link measured deltas to session records and tool execution evidence.

4. Act:
- Keep, revise, or revert the change.
- Record decision rationale and next hypothesis.

## Required experiment record

For each refinement cycle, record these fields in a report artifact under research/local/:

Use template: research/local/templates/refinement-experiment-template.md

- Experiment id: date plus short slug.
- Hypothesis: one sentence with expected measurable effect.
- Change set: list of changed spec/guidance/code files.
- Human guidance inputs: links to inbox docs or direct user instructions used.
- Session evidence:
  - transcript file ids or paths
  - tool call ids where relevant
  - chat-session-resources references where used
- Metrics:
  - baseline values
  - after values
  - delta
  - measurement method
- Validity notes:
  - threats to validity
  - confounders
  - what was held constant
- Decision: adopt, iterate, or rollback.
- Next experiment candidate.

If there is no next experiment candidate, write "None" explicitly.

## Minimum metric set (now)

Use simple code and workflow metrics first:

- command identifier length metrics (mean, median, max)
- alias coverage percent
- repeated module-identity token count
- changed file count
- test pass/fail and count

These are acceptable for early cycles and should be reported before adding advanced metrics.

## Advanced metric set (later)

After baseline discipline is stable, add performance and efficiency metrics:

- end-to-end task completion time
- tool call count per completed task
- retries/rework rate
- build/test duration
- runtime performance metrics for targeted commands

Add one advanced metric family at a time to avoid attribution ambiguity.

## Measurement execution venue

Prefer splitting measurement work into two lanes:

- In-session lane (interactive): run only the minimum checks needed to validate correctness and avoid regressions while iterating.
- Post-commit lane (GitHub workflow): run heavier measurement operations after checkpoint commits so long-running analysis does not stall agent execution.

When using post-commit measurement:

- Keep measurement scripts deterministic and repository-local so workflow runs are reproducible.
- Store artifacts in a consistent location and link them from experiment records.
- Treat post-commit metrics as authoritative for comparisons, and mark in-session readings as provisional.
- If metrics depend on local session history, export a commit-tracked evidence snapshot first because server-side workflows cannot read local workspaceStorage data directly.

### Session evidence export for server-side workflows

When a GitHub workflow needs session-derived metrics, include a lightweight export in the commit, for example:

- A normalized JSON or Markdown snapshot under research/local/ with only fields needed for measurement.
- A source pointer list (transcript ids, tool call ids, and artifact references) used to produce the snapshot.
- A measurement manifest that records export timestamp and script/version used.

Avoid committing raw high-volume transcripts unless they are explicitly required for reproducibility.

## Attribution model

Every observed improvement claim must map to all three inputs:

1. specification change (what changed)
2. human guidance change (why it changed)
3. session evidence (how execution behavior changed)

If one input is missing, downgrade confidence and label the claim provisional.

## Agent execution checklist

Before change:
- confirm experiment hypothesis and success threshold
- capture baseline metrics
- capture relevant inbox assumptions

During change:
- keep edits minimal and isolated to the hypothesis
- record all modified files and rationale

After change:
- run tests and metric collection
- write before/after table with deltas
- tie metrics to session evidence artifacts
- state decision and next experiment

## Reporting style

- Prefer explicit before/after numeric values over qualitative labels.
- Include measurement commands or method notes sufficient for reproduction.
- Separate measured values from projected values.
- Mark unsupported causal claims as hypotheses, not conclusions.
