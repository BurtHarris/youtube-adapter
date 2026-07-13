# Issue tracker: GitHub

Issues and PRDs for this repo live as GitHub issues. Use the gh CLI for all operations.

## External knowledge inbox

Before drafting, triaging, or updating issues for non-trivial work, consult d:/inbox for relevant user-provided context.
Use that context to improve issue accuracy and completeness.

## Autopilot execution cadence

When executing a todo list in autopilot mode:
- Pause for about 10 seconds between todo items to allow user interruption.
- If the user interrupts, stop and re-align before continuing.
- If no interruption occurs, continue automatically with the next todo item.

## Conventions

- **Create an issue**: gh issue create --title "..." --body "...". Use a heredoc for multi-line bodies.
- **Read an issue**: gh issue view <number> --comments, filtering comments by jq and also fetching labels.
- **List issues**: gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]' with appropriate --label and --state filters.
- **Comment on an issue**: gh issue comment <number> --body "..."
- **Apply / remove labels**: gh issue edit <number> --add-label "..." / --remove-label "..."
- **Close**: gh issue close <number> --comment "..."

Infer the repo from git remote -v - gh does this automatically when run inside a clone.

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Run gh issue view <number> --comments.
