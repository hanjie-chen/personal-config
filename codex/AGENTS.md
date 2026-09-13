# Global Guide

## Workflow Fit

- Keep planning lightweight for straightforward work; use a spec or detailed plan only when scope, ambiguity, or coordination risk makes one useful.

## Cross-Repository Work

- Before planning changes or editing files, read the applicable AGENTS.md files from the target repository root to the target files, even when the task starts elsewhere.
- When changing multiple repositories, state which are affected and track each repository's Git state separately.
- For dependent changes across repositories, determine the implementation and verification order before editing.

## Subagents

- Delegate bounded, independent investigations and experiments to subagents when they would produce substantial intermediate information; keep trivial or tightly coupled work in the main agent.
- Keep goals, decisions, and final synthesis in the main agent; have subagents return conclusions, key evidence, and remaining uncertainties rather than full exploration logs, with references to detailed records when needed.

## Direct Investigation

- Perform technical checks yourself when tools and access allow; otherwise, explain the specific blocker before asking me to run them.
