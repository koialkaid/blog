# LY's Blog

一个基于 Hugo 的纯公开个人博客，目标是简单、稳定、低维护、易备份。

## 本地启动

前提：本机已安装 Hugo Extended。

在当前项目目录执行：

```powershell
hugo server -D
```

如果当前 PowerShell 会话拿不到 PATH，可以直接用绝对路径：

```powershell
& "C:\Users\胡艳\AppData\Local\Microsoft\WinGet\Packages\Hugo.Hugo.Extended_Microsoft.Winget.Source_8wekyb3d8bbwe\hugo.exe" server -D
```

默认预览地址：

```text
http://localhost:1313/
```

## 怎么新建文章

正式文章：

```powershell
hugo new content posts/my-post.md
```

日记：

```powershell
hugo new content notes/my-note.md
```

创建后修改对应 Markdown 文件中的：

- `title`
- `date`
- `description`
- `tags`

默认内容结构：

```text
content/
  posts/   正式文章
  notes/   日记
  about/   About 页面
```

## 目录结构说明

```text
.
├─ .github/workflows/   GitHub Pages 发布流程
├─ archetypes/          新内容模板
├─ assets/css/          站点样式
├─ content/             博客内容
├─ layouts/             Hugo 自定义模板
├─ static/              静态资源
└─ hugo.toml            站点配置
```

## 怎么发布到 GitHub Pages

推荐做法：

1. 把这个 `blog` 目录作为一个独立 Git 仓库推到 GitHub
2. 仓库默认分支使用 `main`
3. 保留项目中的 `.github/workflows/hugo.yml`
4. 在 GitHub 仓库的 `Settings > Pages` 中将 Source 设为 `GitHub Actions`
5. 推送到 `main` 后，GitHub Actions 会自动构建并部署

首次推送时常见命令示例：

```powershell
git remote add origin <你的仓库 URL>
git push -u origin main
```

如果你的仓库名是：

- `<username>.github.io`
  站点地址通常就是 `https://<username>.github.io/`
- 其他仓库名
  站点地址通常是 `https://<username>.github.io/<repository>/`

这个项目的 workflow 会在构建时自动读取 GitHub Pages 的基础地址，所以不需要手动把 `baseURL` 改成仓库路径再发布。
`hugo.toml` 里的 `baseURL` 只是本地占位值，真正发布时会被 workflow 覆盖。

## 本地构建

```powershell
hugo --gc --minify --cleanDestinationDir
```

如果构建成功，生成文件会输出到：

```text
public/
```

## 以后如果要绑定域名

等博客已经稳定发布后，再做自定义域名绑定：

1. 在 GitHub 仓库 `Settings > Pages` 中填写自定义域名
2. 在域名 DNS 服务商处添加 GitHub Pages 需要的记录
3. 等证书签发完成后启用 HTTPS

注意：

- 不要只提交 `CNAME` 文件而不在仓库设置中配置域名
- 更推荐先用 `github.io` 地址跑稳，再绑定自己的域名
