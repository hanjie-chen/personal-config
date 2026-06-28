# AGENTS

## Workflow Fit

- For small, well-scoped tasks, act directly or use a short local checklist.
- Use specs, detailed plans, or subagents only when scope, ambiguity, or coordination risk makes them useful.

## Doc Style

- Root README: Chinese, with technical terms in English when clearer.
- `AGENTS.md` and subsystem README files: English by default.

## Subagent Lifecycle

- After collecting a subagent's result, close the completed agent promptly to free its thread slot.
- Do not keep completed implementer or reviewer agents open across unrelated tasks; spawn a fresh agent when new context is needed.

## Evidence-First Investigation

For debugging, performance, environment, network, tool, or configuration questions, verify with evidence instead of giving speculative advice.

- Design and run the experiment yourself when Codex has the needed access and it is safe.
- Use relevant comparisons for causal questions, such as proxy vs direct or old config vs new config.
- Report the evidence, command outcomes, and clear conclusion.
- Ask me to verify only when blocked by access, permissions, risk, credentials, or required physical interaction; state the exact blocker.
