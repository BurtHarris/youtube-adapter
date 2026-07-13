# Implementation Plan Draft: Experiment-Chain Continuity Automation

Date: 2026-07-13
Status: Planned

## Goal

Automate detection of experiment records where the Next Experiment Candidate section is missing, set to None, or not linked to a follow-on record.

## Scope

In scope:
- Scan markdown files under research/local/experiments/.
- Detect section heading "## Next Experiment Candidate".
- Parse candidate line states:
  - Completed reference
  - None
  - freeform candidate text
- Emit a report with actionable recommendations.

Out of scope:
- Automatic editing of experiment records.
- Automatic issue creation.

## Proposed Script

Path:
- scripts/Get-ExperimentChainContinuity.ps1

Inputs:
- -Root (default: research/local/experiments)
- -Recurse
- -OutputPath (optional markdown report)

Outputs:
- Object list with: File, NextCandidateState, ReferenceTarget, Recommendation.
- Optional markdown summary report.

## Detection Rules

1. Missing section:
- State: MissingSection
- Recommendation: Add Next Experiment Candidate section.

2. Explicit None:
- State: None
- Recommendation: Add at least one candidate or justify closure with explicit rationale section.

3. Completed reference found:
- State: Linked
- Recommendation: Verify target file exists and has a valid experiment header.

4. Freeform text candidate:
- State: CandidateText
- Recommendation: Promote candidate into the next experiment record or issue draft.

5. Broken completed reference:
- State: BrokenLink
- Recommendation: Fix path or create referenced record.

## Acceptance Criteria

- Script scans all experiment markdown files in the target root.
- Script returns deterministic state classification per file.
- Script detects broken references in Completed lines.
- Script can emit a markdown report consumable by future triage.

## Test Plan

- Add Pester tests in tests/ for parser and state classification.
- Include fixtures for all five states: MissingSection, None, Linked, CandidateText, BrokenLink.
- Validate report emission path and content shape.

## Suggested Issue Skeleton

Title:
Add experiment-chain continuity scanner for Next Experiment Candidate state

Body key points:
- Why continuity matters for continuous-improvement loops.
- Required states and detection rules.
- Acceptance criteria from this plan.
- Follow-up: integrate into docs/agents/continuous-improvement.md workflow.
