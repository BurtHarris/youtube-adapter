# Refinement as a Scientific Experiment Program

Date: 2026-07-13
Repo: youtube-adapter

## Purpose

Treat refinement work as a continuous-improvement program instead of ad hoc edits.

In this program, each refinement cycle is an experiment with:

- a hypothesis
- measurable before/after outcomes
- traceability to session evidence
- traceability to specification and human-guidance changes

This approach is intended to improve quality now with simple code metrics and to support later optimization using performance metrics.

## Why this model works

Well-documented continuous-improvement programs (for example PDCA and related quality loops) share the same core structure:

1. establish a baseline
2. introduce a controlled change
3. measure outcome deltas with a stable method
4. standardize successful changes or iterate

Applying that structure to coding-agent refinement gives stronger causal evidence than one-off subjective judgments.

## Experiment unit

One experiment should test one primary change axis at a time:

- specification change
- guidance change
- implementation strategy change

Keep scope narrow so effect attribution stays interpretable.

## Traceability model

Each experiment result should tie to three evidence channels:

1. Session records:
- transcript JSONL events
- tool execution sequences
- chat-session-resources payloads where relevant

2. Specification changes:
- edited documents and decisions
- before/after wording for behavioral expectations

3. Human guidance changes:
- direct user instructions
- inbox documents used as guidance inputs

If any channel is missing, classify conclusion confidence as provisional.

## Metrics roadmap

Phase 1 (current): simple code and workflow metrics

- identifier length metrics
- alias coverage
- repeated token counts
- test pass/fail and count
- changed-file scope

Phase 2 (next): execution-efficiency metrics

- task completion time
- tool-call count per completed objective
- rework rate (repeated edit/retest loops)

Phase 3 (later): performance metrics

- command runtime metrics
- build and test duration trends
- bottleneck-specific performance counters

Progress from one phase to the next only after data quality and measurement repeatability are stable.

## Experiment template (minimum)

Standard template path:

- research/local/templates/refinement-experiment-template.md

- Experiment id
- Hypothesis
- Baseline values
- Change set
- After values
- Delta
- Evidence links
- Threats to validity
- Decision (adopt/iterate/rollback)
- Next experiment

## Operating rules

- Prefer numeric before/after values over qualitative labels.
- Separate measured outcomes from projections.
- Keep measurement method constant between baseline and after state.
- Do not claim causality without evidence across all three traceability channels.
- Roll successful patterns into agent guidance so the loop compounds over time.

## Expected outcome

This program turns refinement into an auditable improvement pipeline:

- short-term: better naming/guidance quality with measurable deltas
- medium-term: improved execution efficiency of coding-agent workflows
- long-term: evidence-driven performance optimization with lower regression risk
