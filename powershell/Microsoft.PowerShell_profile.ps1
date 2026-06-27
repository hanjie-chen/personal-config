$script:PromptHasGit = [bool](Get-Command git -ErrorAction SilentlyContinue)

function prompt {
    $previousSuccess = $?
    $previousExitCode = $global:LASTEXITCODE
    $location = Get-Location
    $leaf = Split-Path -Leaf $location.Path
    if (-not $leaf) {
        $leaf = $location.Path
    }

    $branch = $null
    if ($script:PromptHasGit) {
        $branch = git branch --show-current 2>$null
    }

    $global:LASTEXITCODE = $previousExitCode

    $arrow = "`e[38;2;152;195;121m➜`e[0m"
    $path = "`e[38;2;86;182;194m$leaf`e[0m"
    $status = if (-not $previousSuccess) { " `e[38;2;191;97;106m✗`e[0m" } else { "" }
    if ($branch) {
        $git = "`e[38;2;95;170;232mgit:(`e[38;2;208;102;111m$branch`e[38;2;95;170;232m)`e[0m"
        return "$arrow $path $git$status "
    }

    return "$arrow $path$status "
}
# cls

# Custom aliases add by Plain 2024-09-19
function Open-Smart {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    $Path = (Resolve-Path -LiteralPath $Path).ProviderPath

    if (Test-Path -LiteralPath $Path -PathType Container) {
        # It's a folder, open with normal size
        Start-Process -FilePath "explorer.exe" -ArgumentList $Path
    } else {
        # Use cmd's start command so GUI apps do not stay attached to Windows Terminal.
        $startLine = 'start "" /MAX "' + $Path + '"'
        Start-Process -FilePath "cmd.exe" -ArgumentList @("/d", "/c", $startLine) -WindowStyle Hidden
    }
}

# Set alias 'open' for the custom function
Set-Alias -Name open -Value Open-Smart

# custom command add by Plain 2024-09-23
function New-File {
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string[]]$Path
    )

    foreach ($file in $Path) {
        if (Test-Path -Path $file) {
            # File exists, update its timestamp
            (Get-Item $file).LastWriteTime = Get-Date
            Write-Host "Updated timestamp: $file"
        }
        else {
            # File doesn't exist, create it
            New-Item -ItemType File -Path $file | Out-Null
            Write-Host "Created new file: $file"
        }
    }
}

Set-Alias -Name touch -Value New-File
# add by Plain in 2024-10-05
$PSStyle.FileInfo.Directory = "`e[34;1m"  # bule bold for directory
$PSStyle.FileInfo.SymbolicLink = "`e[36;1m" 
$PSStyle.FileInfo.Executable = "`e[32;1m"  # green boldfor exe file

# seeting color for differnet file
$colors = @{
    ".txt" = "`e[33m"  # yellow
    ".log" = "`e[31m"  # red
    ".ps1" = "`e[36m"  
    ".exe" = "`e[32m"  # green
    ".json" = "`e[35m"  
    ".yml" = "`e[35m"  
    ".md" = "`e[33m"   # yellow
}
# apply it to color
foreach ($extension in $colors.Keys) {
    $PSStyle.FileInfo.Extension[$extension] = $colors[$extension]
}

# Linux-like tree command, added by Plain in 2024-11-15
function Show-TreeWithFiles {
    param (
        [string]$Path = ".",
        [string]$Indent = "",
        [bool]$IsLast = $true,
        [switch]$DirectoriesOnly, # 新增参数，使用 switch 类型便于命令行使用
        [string[]]$Ignore  # 新增 Ignore 参数
    )

    # 根据 DirectoriesOnly 参数决定是否只获取目录
    $items = if ($DirectoriesOnly) {
        Get-ChildItem -Path $Path | Where-Object { $_.PSIsContainer }
    } else {
        Get-ChildItem -Path $Path
    }
    # 如果指定 Ignore 过滤掉匹配的文件夹
    if ($Ignore) {
        $items = $items | Where-Object { $Ignore -notcontains $_.Name }
    }
    
    $count = $items.Count
    $current = 0

    foreach ($item in $items) {
        $current++
        $isLastItem = ($current -eq $count)
        $prefix = if ($Indent -eq "") {
            if ($isLastItem) { "└───" } else { "├───" }
        } else {
            if ($isLastItem) { "$Indent└───" } else { "$Indent├───" }
        }

        # 使用 Write-Host 的 -NoNewline 参数来分段输出
        Write-Host "$prefix" -NoNewline

        # 使用 $PSStyle.FileInfo 的颜色设置
        if ($item.PSIsContainer) {
            # 目录使用 Directory 的颜色设置
            Write-Host ($PSStyle.FileInfo.Directory + $item.Name + $PSStyle.Reset)
        } else {
            # 文件使用对应扩展名的颜色设置
            $extension = $item.Extension.ToLower()
            $colorCode = $PSStyle.FileInfo.Extension[$extension]
            if ($colorCode) {
                Write-Host ($colorCode + $item.Name + $PSStyle.Reset)
            } else {
                # 如果没有定义颜色，使用默认颜色
                Write-Host $item.Name
            }
        }

        if ($item.PSIsContainer) {
            $newIndent = if ($Indent -eq "") {
                if ($isLastItem) { "    " } else { "│   " }
            } else {
                if ($isLastItem) { "$Indent    " } else { "$Indent│   " }
            }
            Show-TreeWithFiles -Path $item.FullName -Indent $newIndent -IsLast $isLastItem -DirectoriesOnly:$DirectoriesOnly -Ignore:$Ignore
        }
    }
}

# 创建别名，使用 -Force 参数覆盖原有的 tree 命令
Set-Alias -Name tree -Value Show-TreeWithFiles -Force
