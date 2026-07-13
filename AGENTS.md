## Agent skills

### Issue tracker

GitHub Issues are the source of truth for issues and PRDs in this repo (via gh). See docs/agents/issue-tracker.md.

### Triage labels

Triage uses the default five-label vocabulary with no overrides. See docs/agents/triage-labels.md.

### Domain docs

Domain docs are single-context (root CONTEXT.md and root docs/adr/). See docs/agents/domain.md.

### Continuous improvement experiments

Run refinement as a measurable experiment program tied to session evidence, specification changes, and human guidance updates. See docs/agents/continuous-improvement.md.

### External knowledge inbox

Consult d:/inbox for additional user-provided knowledge before planning or implementing non-trivial changes.
Use relevant documents from d:/inbox as supporting context alongside repository docs.

### Autopilot execution cadence

When executing a todo list in autopilot mode:
- Pause for about 10 seconds between todo items to allow user interruption.
- If the user interrupts, stop and re-align before continuing.
- If no interruption occurs, continue automatically with the next todo item.
- When a ticket is resolved and closed, create a checkpoint commit and compact context before retrieving the next ticket.
