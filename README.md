# personal-config

个人使用的软件配置仓库，用来保存长期维护和跨机器同步的配置。

仓库管理可移植的配置偏好、规则和模板；每台机器的完整配置与运行状态留在本机。对于同时包含通用偏好和本机信息的配置文件，只保存需要共享的片段，并在使用时合并到本机配置中。

## 当前配置模块

- `codex/`: Codex global instructions、代码项目 `AGENTS.md` 模板与跨机器共享的配置片段。
- `git/`: Git 全局配置，包括 .gitignore 和 .gitattributes。
- `powershell/`: PowerShell 7 custom profile。
- `proxy/`: 个人代理分流规则，使用逻辑 target 表达规则意图，不绑定具体客户端策略组名；当前 Windows 机器通过 Clash Verge Rev 的 Profile Enhancement Rules 接入。

## 使用方式

建议将仓库克隆到：

```bash
~/projects/personal-config
```

### Codex

文件用途与代码项目模板见 [`codex/README.md`](codex/README.md)。

把仓库中的 Codex 全局指导文件链接到 `~/.codex`：

```bash
mkdir -p ~/.codex
ln -sf ~/projects/personal-config/codex/AGENTS.md ~/.codex/AGENTS.md
```

跨机器通用偏好保存在 [`codex/config.shared.toml`](codex/config.shared.toml)，按 [`codex/README.md`](codex/README.md) 中的步骤手动合并到本机配置。仓库不管理完整的 `~/.codex/config.toml`，也不将它链接到仓库；机器路径、项目信任记录、插件 runtime、MCP server 等本机配置继续在各机器维护。

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
