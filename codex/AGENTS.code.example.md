# Repository Guide

## Read First

- Start with the root `README.md` and read the applicable `AGENTS.md` files on the path from the repository root to the target files before planning changes or editing.
- Before planning or making non-trivial changes in a subsystem, read its nearest `README.md`.

## Design Principles

- This is a personal project. Backward compatibility is not required, and breaking changes are acceptable. Remove superseded code instead of keeping compatibility layers, and update affected callers and configuration within the task's scope.
- Prefer the simplest solution that fully addresses the problem and related cases within the current requirements. Do not optimize for the smallest diff or add abstractions for hypothetical needs.
- Treat existing implementation choices as revisable, not as requirements. Preserve explicit user constraints.

## Documentation

- Keep the root `README.md` as a concise repository entry point; use subsystem `README.md` files as the source of truth for subsystem-specific behavior and details.
- Write the root `README.md` in Chinese, using English technical terms when clearer; write `AGENTS.md` and subsystem `README.md` files in English by default.
- Update the relevant root or subsystem `README.md` files in the same change when their descriptions would otherwise become outdated.

## Verification

- Determine verification scope from the affected behavior, including consumers of shared components. Verify the intended outcome and key neighboring cases that should remain unaffected. When a failure reveals a shared assumption, check other tests that rely on it.
- Run the smallest set of checks that covers this scope during development. Complete the project's required checks and resolve related failures before finishing.
- Keep automated tests deterministic; do not call live external services from tests.
- For documentation-only changes, review accuracy and run `git diff --check`; the full test suite is not required.

## Git Workflow

- Work directly on `main` by default. Create a branch or PR only when explicitly requested by the user.
