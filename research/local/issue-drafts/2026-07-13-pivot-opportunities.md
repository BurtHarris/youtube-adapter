# Issue Drafts: Pivot Opportunities (2026-07-13)

Purpose: Provide issue-ready drafts for Explore-now candidates captured in the pivot opportunity ledger.

## Draft 1: Add Session Pending-Work Stack with Reflection Checkpoints

Title: Add session pending-work stack with periodic reflection checkpoints

Problem:
Execution is intentionally non-linear. Without explicit queue tracking and reflection, pivots can fragment context and hide unfinished work.

Proposed change:
- Maintain a LIFO pending-work stack in session memory.
- Trigger reflection blocks after each substantive work burst.
- Standardize reflection format: Delta, Insight, Decision, Next.

Acceptance criteria:
- A session stack file is maintained during active work.
- Reflection snapshots are posted periodically during execution.
- Completed and deferred items are explicitly tracked.

Out of scope:
- Persistent cross-repo queue orchestration.

Suggested labels:
- enhancement
- workflow

## Draft 2: Add Pivot-Triage Workflow (Explore now vs Future work vs Parked)

Title: Add pivot triage workflow for in-session idea handling

Problem:
Pivots arrive during implementation and can either be valuable direction changes or distractions. A triage policy is needed to decide quickly.

Proposed change:
- Record each pivot event with a short rationale.
- Classify each pivot into Explore now, Future work, or Parked.
- Add keep/drop/defer guidance at each pivot checkpoint.

Acceptance criteria:
- Pivot log entries are created as pivots occur.
- Every pivot has a recommendation with rationale.
- Deferred pivots are captured in a durable ledger.

Out of scope:
- Automatic prioritization scoring based on telemetry.

Suggested labels:
- enhancement
- process

## Draft 3: Mine Copilot Evidence for Uncaptured Opportunity Candidates

Title: Mine session evidence for uncaptured product/service/project opportunities

Problem:
Some product/service/project opportunities surface in transcripts and local research artifacts but never get promoted to issues.

Proposed change:
- Define an intake pass over transcript artifacts and local research docs.
- Categorize findings as Product, Service, or Project.
- Store candidates in a ledger with signal and recommendation.

Acceptance criteria:
- A repeatable evidence-mining pass is documented and executed.
- New candidates are categorized and recorded with recommendation.
- Explore-now items are prepared for issue promotion.

Out of scope:
- Full NLP summarization pipeline.

Suggested labels:
- enhancement
- research
- triage

## Draft 4: Concise Cmdlet Transition with Compatibility Aliases and Decode Utility

Title: Transition to concise cmdlet names with compatibility aliases and deterministic decode utility

Problem:
The current command surface is naming-heavy and repeats module identity tokens, reducing token efficiency and readability.

Proposed change:
- Introduce concise canonical cmdlet names.
- Keep compatibility aliases from existing verbose names during migration.
- Add explicit alias export/manifest policy.
- Add decode utility to expand aliases into canonical syntax for audit/interoperability.

Acceptance criteria:
- Concise canonical cmdlets are exported.
- Backward compatibility aliases are documented and tested.
- A deterministic decode/normalize command exists and is documented.
- Import-Module -Prefix guidance is documented for collision handling.

Out of scope:
- Removal of compatibility aliases in the initial transition.

Suggested labels:
- enhancement
- breaking-change-managed
- powershell

## Notes

Source candidate file: research/local/pivot-opportunity-ledger.md
Promotion policy reference: docs/agents/issue-tracker.md
