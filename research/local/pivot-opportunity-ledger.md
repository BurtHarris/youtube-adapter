# Pivot Opportunity Ledger

Purpose: Capture pivots and latent ideas that emerge during execution before they become GitHub issues.

## Intake Categories

- Product: user-facing capability, workflow, or experience opportunity.
- Service: automation, integration, or operational capability opportunity.
- Project: bounded implementation effort suitable for issue decomposition.

## Prioritization Labels

- Explore now: worth immediate spike or implementation.
- Future work: valuable but defer until current scope completes.
- Parked: low confidence or blocked by missing evidence.

## Active Intake

| Date | Source | Category | Candidate | Signal | Recommendation | Next capture step |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-07-13 | Session pivot | Service | Maintain a live pending-work stack in-session with periodic reflection checkpoints | High: explicit user request tied to workflow preference | Explore now | Keep stack in session memory and summarize after each meaningful work burst |
| 2026-07-13 | Session pivot | Product | Pivot-aware coaching that classifies new ideas as now vs future and suggests direction | High: explicit user request | Explore now | Record each pivot with keep/drop/defer and rationale |
| 2026-07-13 | Session introspection | Project | Mine Copilot evidence for uncaptured issue candidates and categorize into product/service/project | Medium-High: desired by user, partial data available | Explore now | Use transcript artifacts + local evidence files; emit candidate list for issue drafting |
| 2026-07-13 | Experiment chain review | Service | Automate experiment-chain continuity detection and candidate generation when Next Experiment Candidate is None | Medium: current chain stops at phase3 with no candidate | Future work | Draft a script that scans experiment records and proposes next candidate templates |
| 2026-07-13 | Compliance report mining | Project | Execute concise cmdlet naming transition with compatibility aliases and deterministic decode utility | Medium-High: documented recommendation with measurable mitigation gains | Explore now | Convert recommended next steps into scoped GitHub issues with transition plan |

## Promotion Rule

When a candidate reaches Explore now with clear scope and acceptance criteria, promote it to a GitHub issue per docs/agents/issue-tracker.md.

## Execution Updates

- 2026-07-13: Draft issue package created for Explore-now candidates in research/local/issue-drafts/2026-07-13-pivot-opportunities.md.
- 2026-07-13: Future-work continuity item converted into implementation-plan draft in research/local/issue-drafts/2026-07-13-experiment-chain-continuity-plan.md.
