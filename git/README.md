# Git 配置

这个目录保存个人常用的 Git 全局配置。

## 全局 ignore

`git/.gitignore` 用作全局 ignore 文件，适合放跨项目都不希望提交的内容，例如本地环境文件、缓存文件和工具生成文件。

```bash
ln -sf ~/personal-config/git/.gitignore ~/.gitignore
git config --global core.excludesFile ~/.gitignore
```

可以用下面的命令检查是否生效：

```bash
git config --global --get core.excludesFile
git check-ignore -v .env
```

## 全局 attributes

`git/.gitattributes` 用作全局 attributes 文件，目前主要用于统一文本文件行尾。

```bash
ln -sf ~/personal-config/git/.gitattributes ~/.gitattributes
git config --global core.attributesFile ~/.gitattributes
```

可以用下面的命令检查是否生效：

```bash
git config --global --get core.attributesFile
```
