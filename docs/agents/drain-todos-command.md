# drain-todos command

This repo defines a reusable slash prompt command: /drain-todos.

Location:

- .github/prompts/drain-todos.prompt.md

## Purpose

Run the active todo queue in autopilot mode until drained, while preserving safety and traceability.

## Behavior contract

- Process work in queue order unless dependencies require a different order.
- Report progress item-by-item.
- After every closed ticket:
  - create a checkpoint commit
  - compact context in /memories/session/todo.md
  - only then retrieve the next ticket
- Stop only on:
  - explicit user interruption
  - a hard blocker that requires user input
  - an empty queue

## Scope

The command is repo-scoped first. If desired, copy the same prompt to user prompts for global use.

## Recommended usage

1. Invoke /drain-todos.
2. Let the agent continue automatically between items.
3. Interrupt at any checkpoint if reprioritization is needed.
