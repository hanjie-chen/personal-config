# Proxy 配置

这个目录保存个人代理分流规则。仓库只维护长期稳定的规则意图，不保存具体客户端的运行时配置、订阅 URL、节点信息或本机脚本。

## 文件

- `rules.yml`: 本地 overlay 规则源文件。

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

`logical-target` 需要在本机 Clash 配置目录中映射到真实策略组：

```yaml
targets:
  proxy: 🔰 节点选择
  fallback: 🐟 漏网之鱼
```

这个本机映射文件不放进仓库，因为不同机器的策略组名可能不同。

## 本机接入示例

本仓库不规定具体代理客户端。当前 Windows 机器使用 Clash for Windows，并在本机 Clash 配置目录维护 glue script 和 target 映射：

```powershell
~\.config\clash\codex-proxy-targets.yml
~\.config\clash\codex-maintain-proxy-rules.ps1
~\.config\clash\codex-watch-proxy-rules.ps1
```

这些文件属于机器本地 glue，不纳入本仓库。脚本会读取本仓库的 `proxy/rules.yml`，将逻辑 target 映射到本机 Clash 策略组，并生成 Clash 运行时配置。

手动合并并重新加载当前 Clash 配置：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ~\.config\clash\codex-maintain-proxy-rules.ps1
```

启动文件变化监听。这个 watcher 是事件触发式的常驻进程：订阅 YAML 被 Clash 更新后，Windows 文件系统通知 watcher，watcher 再运行本机合并脚本。

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ~\.config\clash\codex-watch-proxy-rules.ps1
```
