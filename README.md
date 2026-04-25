# personal-config

这是我个人使用的一些软件与机器配置仓库，用于保存适合长期维护和跨机器同步的稳定配置。

## 当前配置模块

- `codex/`: Codex 配置，通过软链接到 `~/.codex` 使用。
- `git/`: Git 全局配置，包括 ignore 和 attributes。详见 `git/README.md`。

## 这个仓库的作用

这个仓库不直接替代整个 home 目录，而是按工具拆分配置目录，例如 `codex/`、`git/`。实际使用时，再把需要的文件软链接到对应工具期望的位置。

## 使用方式

建议将仓库克隆到：

```bash
~/personal-config
```

### Codex

把仓库中的 Codex 配置链接到 `~/.codex`：

```bash
mkdir -p ~/.codex
ln -sf ~/personal-config/codex/AGENTS.md ~/.codex/AGENTS.md
ln -sf ~/personal-config/codex/config.toml ~/.codex/config.toml
```

### Git

Git 全局 ignore 和 attributes 需要额外设置 Git 配置项，见 `git/README.md`。

## 说明

`config.toml` 中可能包含当前机器上的项目路径配置；如果在新机器上使用，需要检查并按实际路径调整。
