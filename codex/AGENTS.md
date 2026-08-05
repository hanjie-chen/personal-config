# Global Guide

## Workflow Fit

- Keep planning lightweight for straightforward work; use a spec or detailed plan only when scope, ambiguity, or coordination risk makes one useful.

## Cross-Repository Work

- Repository-specific rules follow the target repository, not the session: before planning or making changes in any Git repository, identify the target repository and read every applicable AGENTS.md from its root to the target path, plus the root README and relevant subsystem documentation, even when the session started elsewhere.
- When work spans repositories, state which repositories are affected and track each repository's Git state separately; when changes depend on one another, decide the order of changes and verification before modifying any of them.

## Subagents

- Use subagents for bounded, independent work when parallelism or context isolation would materially help, especially for noisy investigations and experiments; keep trivial or tightly coupled work in the main agent.
- Keep goals, decisions, and final synthesis in the main agent; require subagents to return concise evidence and conclusions.
- When a subagent completes its task, collect its result, then close its thread to release the slot; use a fresh subagent for unrelated work.

## Direct Investigation

- For technical or configuration questions that can be safely investigated with available tools, perform the relevant checks, use comparisons for causal questions, and report the evidence and conclusion instead of asking me to run commands.
- Ask me to verify only when blocked by access, permissions, risk, credentials, or required physical interaction; state the exact blocker.
