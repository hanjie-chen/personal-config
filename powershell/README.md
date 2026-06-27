# PowerShell 配置

这个目录保存当前用户的 PowerShell 7 交互式 profile。

目前只管理 `Microsoft.PowerShell_profile.ps1`，对应：

```powershell
$PROFILE.CurrentUserCurrentHost
```

也就是 Windows Terminal 中 PowerShell 7 日常交互 shell 会加载的 profile。

暂不管理 `profile.ps1`，因为当前没有需要所有 PowerShell host 共同加载的配置。

## 使用方式

确认内容后，将仓库中的 profile 软链接到 PowerShell 期望的位置：

```powershell
New-Item -ItemType Directory -Force -Path "$HOME\Documents\PowerShell"

New-Item -ItemType SymbolicLink `
  -Path "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" `
  -Target "E:\Personal_Project\personal-config\powershell\Microsoft.PowerShell_profile.ps1"
```
