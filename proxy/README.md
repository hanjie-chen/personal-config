# Proxy 配置

这个目录保存个人代理分流规则。仓库只维护长期稳定的规则意图和可复用生成器，不保存具体客户端的运行时配置、订阅 URL、节点信息。

## 文件

- `rules.yml`: 本地 overlay 规则源文件。
- `Apply-ClashVergeRules.ps1`: 将 `rules.yml` 写入当前 Clash Verge Rev profile 的 Profile Enhancement Rules 文件。

## 规则格式

`rules.yml` 的 `prepend-rules` 每一行格式为：

```yaml
- RULE-TYPE,value,logical-target
```

示例：

```yaml
- DOMAIN-SUFFIX,linkedin.com,proxy
- DOMAIN-SUFFIX,openai.com,fallback
```

`logical-target` 需要在本机 Clash/Clash Verge 配置目录中映射到真实策略组：

```yaml
targets:
  proxy: 🔰 节点选择
  fallback: 🐟 漏网之鱼
```

这个本机映射文件不放进仓库，因为不同机器的策略组名可能不同。

## Clash Verge Rev 接入

当前 Windows 机器使用 Clash Verge Rev，采用 Verge 的 Profile Enhancement 机制接入：

- `rules.yml` 仍是仓库内唯一的规则源。
- 本机 target 映射放在 `%APPDATA%\io.github.clash-verge-rev.clash-verge-rev\codex-proxy-targets.yml`。
- 生成器读取 Verge 的 `profiles.yaml`，找到当前订阅 profile 绑定的 `option.rules` profile 文件，然后写入 `prepend` 规则。
- 这属于 Profile Enhancement Rules，不直接改订阅 YAML，也不把节点、订阅 URL 或运行时状态写回仓库。

本机 target 映射示例：

```yaml
targets:
  proxy: 🔰 节点选择
  fallback: 🐟 漏网之鱼
```

手动生成当前 Clash Verge Rev profile 的 rules enhancement：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\proxy\Apply-ClashVergeRules.ps1
```

这个命令的作用是把仓库里的 `proxy/rules.yml` 同步到当前 Clash Verge Rev profile 绑定的 Rules Enhancement 文件里。它不会直接修改订阅 YAML，也不会把节点信息写进仓库。

命令参数含义：

- `pwsh`: 使用 PowerShell 7 运行脚本。
- `-NoProfile`: 不加载当前用户的 PowerShell profile，避免本机别名或函数影响脚本行为。
- `-ExecutionPolicy Bypass`: 只对这一次执行放行脚本执行策略，不修改系统策略。
- `-File .\proxy\Apply-ClashVergeRules.ps1`: 指定要运行的生成器脚本。

不需要每次开机或每次打开 Clash Verge 都运行。只有以下情况需要运行一次：

- 修改了 `proxy/rules.yml`。
- 修改了本机 target 映射文件。
- Clash Verge 当前订阅/profile 换了，导致绑定的 Rules Enhancement 文件变化。

如果当前目录已经是 `proxy/`：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\Apply-ClashVergeRules.ps1
```

脚本默认会尝试请求 Mihomo controller 重新加载当前运行时配置。但 Clash Verge 的 profile enhancement 是应用层合成配置：如果 `clash-verge.yaml` 没有立刻出现新规则，需要在 Clash Verge UI 中重新应用/刷新当前订阅 profile，让 Verge 重新生成运行时配置。

## 机制选择

当前选择 Profile Enhancement Rules，而不是把规则直接 merge 到运行时 YAML：

- Rules enhancement 天然支持 `prepend`/`append`/`delete`，适合维护分流规则。
- Merge enhancement 更适合维护 `profile`、`dns`、`tun` 等结构化配置。
- 直接修改 `clash-verge.yaml` 会被订阅刷新或 Verge 重建覆盖，只适合临时排障，不适合作为长期机制。
