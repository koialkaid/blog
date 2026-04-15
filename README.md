# Koi's Blog

一个基于 Hugo 的个人博客仓库。

线上地址：

[https://koialkaid.github.io/blog/](https://koialkaid.github.io/blog/)

## 简介

这个仓库保存的是博客的内容、模板、样式和发布流程。

博客整体保持轻量、公开、低维护的方向：

- 以写作为主
- 使用静态站点方案
- 内容保存在 Git 仓库里
- 通过 GitHub Pages 对外发布

## 技术栈

- [Hugo](https://gohugo.io/)
- [GitHub Pages](https://pages.github.com/)
- [GitHub Actions](https://github.com/features/actions)
- [Pages CMS](https://pagescms.org/)

## 内容结构

```text
content/
  posts/   正式文章
  notes/   日记
  about/   About 页面
  todo/    待办页面
```

其中：

- `posts` 用来放相对完整一点的文章
- `notes` 用来放短一点的记录和日记
- `about` 用来说明这个博客的来源和写作方式
- `todo` 用来记录博客相关的待办事项

## 发布方式

这个仓库使用 GitHub Actions 构建 Hugo 站点，并发布到 GitHub Pages。

也就是说，内容更新后的大致链路是：

```text
写内容
→ 提交到仓库
→ GitHub Actions 构建
→ GitHub Pages 发布
```

## 写作方式

目前这个博客支持两种写法：

1. 直接编辑仓库中的 Markdown 文件
2. 通过 Pages CMS 在后台写作，内容仍然回写到 Git 仓库

不管用哪一种方式，最终发布的前台仍然是 Hugo 生成的静态页面。

## 说明

这是一个个人博客仓库，不提供评论、账号系统或私密内容存储。

仓库中公开保留的是：

- 博客内容
- 站点模板与样式
- 发布流程配置

不会在公开仓库中保留本地机器路径、个人环境细节或其他不必要的隐私信息。
