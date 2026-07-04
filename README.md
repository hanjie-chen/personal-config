# personal-config

这是我个人使用的软件配置仓库，用于保存适合长期维护和跨机器同步的稳定配置。

## 当前配置模块

- `codex/`: Codex 全局指导文件，只同步 `AGENTS.md`。
- `git/`: Git 全局配置，包括 ignore 和 attributes。详见 `git/README.md`。
- `powershell/`: PowerShell 7 当前用户交互式 profile。
- `proxy/`: 个人代理分流规则，使用逻辑 target 表达规则意图，不绑定具体客户端策略组名；当前 Windows 机器通过 Clash Verge Rev 的 Profile Enhancement Rules 接入。

## 使用方式

建议将仓库克隆到：

```bash
~/projects/personal-config
```

### Codex

把仓库中的 Codex 全局指导文件链接到 `~/.codex`：

```bash
mkdir -p ~/.codex
ln -sf ~/projects/personal-config/codex/AGENTS.md ~/.codex/AGENTS.md
```

不管理 `~/.codex/config.toml`。它包含机器路径、桌面端设置、插件 runtime、MCP server 等本机生成或本机差异较大的配置，应留在各机器本地维护。

### Git

Git 全局 ignore 和 attributes 需要额外设置 Git 配置项，见 `git/README.md`。

### PowerShell

PowerShell 7 当前用户交互式 profile 见 `powershell/README.md`。

### Proxy

代理分流规则见 `proxy/README.md`。仓库只保存跨机器稳定的规则源文件和生成器；每台机器需要在本地 Clash/Clash Verge 配置目录维护自己的 target 映射。

当前 Windows/Clash Verge Rev 机器的接入命令：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\proxy\Apply-ClashVergeRules.ps1
```
