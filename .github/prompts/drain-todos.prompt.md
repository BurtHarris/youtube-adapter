---
mode: agent
description: Drain the active todo queue end-to-end with checkpoint commits and context compaction between tickets.
---

Execute in autopilot mode using this contract:

1. Load session todos from /memories/session/todo.md if present.
2. Continue processing queued work until no actionable items remain.
3. Work one ticket/item at a time and report progress after each item.
4. After closing a ticket, make a checkpoint commit before retrieving the next ticket.
5. After the checkpoint commit, compact context by updating /memories/session/todo.md with:
- what was completed
- checkpoint commit id
- next item to retrieve
6. Stop only when one of these is true:
- todo queue is empty
- explicit user interruption is received
- hard blocker requires user input (decision, secret, access, or missing prerequisite)
7. On stop, publish a concise status summary with completed items and remaining queue.

Guardrails:

- Ignore unrelated workspace changes unless explicitly instructed.
- Never revert user changes unless explicitly requested.
- Keep commits scoped to intentional files for the current item.
