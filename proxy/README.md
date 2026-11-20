# 个人代理分流规则

`rules.yml` 是规则的唯一维护源；`Apply-ClashVergeRules.ps1` 将它生成到 Clash Verge 的规则增强文件。仓库不保存订阅 URL、节点信息或客户端完整配置。

## 当前偏好

- OpenAI、Google/Gemini、Claude/Anthropic、GitHub/Copilot：代理。
- Bilibili、国内抖音、Outlook/Teams：直连。
- 保留规则顺序；共享 CDN 使用具体域名，不扩大到整个父域名。Microsoft 登录和资源域名也可能被其他应用共用。

目前共 113 条；精确域名、IP 范围和顺序以 `rules.yml` 为准。规则仅影响进入 Clash 的流量，不保证网站功能或会议媒体一定可用。

## 本机接入

规则使用 `proxy` / `direct` 表达意图。每台机器在 `%APPDATA%\io.github.clash-verge-rev.clash-verge-rev\codex-proxy-targets.yml` 配置实际策略组，不将这个本机文件提交到仓库。

当前 Windows 的映射：

```yaml
targets:
  proxy: PROXY
  direct: DIRECT
```

重装后先在 Clash Verge 导入客户端配置，再创建上述映射。其他机器按自己的策略组名填写；仓库规则不会自动同步到其他设备。

从仓库根目录运行：

```powershell
# 检查映射和当前 profile，不写入
pwsh -NoProfile -File .\proxy\Apply-ClashVergeRules.ps1 -ProfileName sg -WhatIf

# 写入 sg 的规则增强文件
pwsh -NoProfile -File .\proxy\Apply-ClashVergeRules.ps1 -ProfileName sg
```

`sg` 必须是当前选中的 profile，且使用独立的规则增强文件；其他机器传入对应名称。脚本拒绝空规则、无效映射以及已有的非空 append/delete，避免覆盖额外配置。IP 规则的 `no-resolve` 选项会保留。

脚本只生成增强文件，不重载旧的运行配置。规则改变后，在 Clash Verge 重新应用当前 profile，随后检查实际规则匹配。修改规则、映射或接入 profile 后才需要重新生成，无需开机定时运行。

只编辑仓库里的规则源。Clash 中的增强文件是生成结果，`clash-verge.yaml` 是运行结果；直接修改它们会在下次生成时被覆盖。使用 `-OutputPath <临时文件>` 可预览生成内容。
