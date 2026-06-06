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

## Evidence-First Investigation

When I ask Codex to investigate a technical issue, performance problem, environment problem, network problem, tool behavior, or configuration question, do not stop at suggestions like "you can try..." or "please verify...".

Instead:
- Design a concrete experiment or diagnostic sequence.
- Run the commands or tool calls yourself when available and safe.
- Compare at least two relevant cases when the question is causal, such as proxy vs direct, old config vs new config, or failing path vs working path.
- Report the measured evidence, command outcomes, and a clear conclusion.
- Prefer experimental verification over speculative advice.
- Do not delegate verification to me when Codex can reasonably perform it.
- Only ask me to verify manually when Codex cannot access the needed system, lacks permission, the action is destructive/high-risk, or the experiment requires credentials or physical interaction unavailable to Codex.
- If blocked, state the exact blocker and the smallest thing needed from me.
