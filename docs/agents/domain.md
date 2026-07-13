# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## External knowledge inbox

Before exploring non-trivial topics, consult d:/inbox for relevant user-provided knowledge.
Use applicable inbox material alongside the repo domain docs in this file.

## Autopilot execution cadence

When executing a todo list in autopilot mode:

- Pause for about 10 seconds between todo items to allow user interruption.
- If the user interrupts, stop and re-align before continuing.
- If no interruption occurs, continue automatically with the next todo item.

## Before exploring, read these

- **CONTEXT.md** at the repo root, or
- **CONTEXT-MAP.md** at the repo root if it exists - it points at one CONTEXT.md per context. Read each one relevant to the topic.
- **.devdrive/docs/adr/** - read ADRs that touch the area you're about to work in. In multi-context repos, also check src/[context]/docs/adr/ for context-scoped decisions.

If any of these files don't exist, **proceed silently**. Don't flag their absence; don't suggest creating them upfront. The producer skill (/grill-with-docs) creates them lazily when terms or decisions actually get resolved.

## File structure

Single-context repo (most repos):

/
|- CONTEXT.md
|- .devdrive/docs/adr/
|  |- 0001-event-sourced-orders.md
|  `- 0002-postgres-for-write-model.md
`- src/

Multi-context repo (presence of CONTEXT-MAP.md at the root):

/
|- CONTEXT-MAP.md
|- .devdrive/docs/adr/                <- system-wide decisions
`- src/
   |- ordering/
   |  |- CONTEXT.md
   |  docs/adr/                     ← context-specific decisions
   `- billing/
      |- CONTEXT.md
      `- docs/adr/

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in CONTEXT.md. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal - either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for /grill-with-docs).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders) - but worth reopening because..._
