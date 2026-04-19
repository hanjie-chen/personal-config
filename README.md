# personal-config

这是我个人使用的一些软件与机器配置仓库，目前主要同步 Codex 相关配置。

## 当前跟踪的文件

- `.codex/AGENTS.md`
- `.codex/config.toml`

## 这个仓库的作用

这个仓库保存适合长期维护和跨机器同步的稳定配置。

目前 `~/.codex/AGENTS.md` 和 `~/.codex/config.toml` 通过软链接指向本仓库中的对应文件，因此可以一边正常让 Codex 读取，一边用 Git 管理版本。

## 使用方式

建议将仓库克隆到：

```bash
~/personal-config
```

然后把仓库中的文件链接到 `~/.codex`：

```bash
ln -sf ~/personal-config/.codex/AGENTS.md ~/.codex/AGENTS.md
ln -sf ~/personal-config/.codex/config.toml ~/.codex/config.toml
```

## 说明

`config.toml` 中可能包含当前机器上的项目路径配置；如果在新机器上使用，需要检查并按实际路径调整。
