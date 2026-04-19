# AGENTS

## Working Style

- Keep changes focused.
- Do not mix unrelated refactors into the same task.

## Workflow Fit

- Prefer direct implementation or a short local checklist for small, well-scoped changes.
- Use heavier spec, plan, or subagent-driven workflows only when scope, ambiguity, or coordination risk justifies them.

## Subagent Hygiene

- Close subagents promptly once their task and role are complete.
- Do not keep finished implementer or reviewer agents open across unrelated tasks.
- Open a fresh subagent for the next task unless continued context is immediately necessary.
