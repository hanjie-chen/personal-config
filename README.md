# personal-config

这是我个人使用的软件配置仓库，用于保存适合长期维护和跨机器同步的稳定配置。

## 当前配置模块

- `codex/`: Codex 全局指导文件，只同步 `AGENTS.md`。
- `git/`: Git 全局配置，包括 ignore 和 attributes。详见 `git/README.md`。

## 使用方式

建议将仓库克隆到：

```bash
~/personal-config
```

### Codex

把仓库中的 Codex 全局指导文件链接到 `~/.codex`：

```bash
mkdir -p ~/.codex
ln -sf ~/personal-config/codex/AGENTS.md ~/.codex/AGENTS.md
```

不管理 `~/.codex/config.toml`。它包含机器路径、桌面端设置、插件 runtime、MCP server 等本机生成或本机差异较大的配置，应留在各机器本地维护。

### Git

Git 全局 ignore 和 attributes 需要额外设置 Git 配置项，见 `git/README.md`。
