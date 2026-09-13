# Codex Instructions, Templates, and Shared Configuration

- `AGENTS.md`: global instructions installed at `~/.codex/AGENTS.md`.
- `AGENTS.code.example.md`: starter template to copy and adapt into a code project's `AGENTS.md`.
- `config.shared.toml`: portable preferences to merge manually into each machine's user configuration; Codex does not load this fragment automatically.

The global instructions were last reviewed with GPT-6 Astra at medium reasoning effort. They reflect personal workflow preferences rather than model-specific requirements.

See the [root README](../README.md) for global instructions installation.

## Shared configuration

Keep cross-machine preferences in this repository. Each machine's complete configuration, including paths, project trust records, MCP settings, and plugin runtime details, stays local.

Merge the fragment into `~/.codex/config.toml` on Linux/macOS or `%USERPROFILE%\.codex\config.toml` on Windows (or `CODEX_HOME/config.toml` when set). Update matching keys in their existing TOML sections, preserving other settings; do not overwrite the whole file or duplicate table headers. Keep the subagent model and reasoning effort settings together.

Reapply changes manually on each machine, then start a new Codex task to use the updated defaults.
