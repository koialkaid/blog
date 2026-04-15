+++
title = 'About'
description = '博客的技术栈、写作方式等。'
+++
你好，这里是 Koi's Blog。

这是一个从 **2026 年 4 月 9 日** 开始搭起来的个人博客。

## 这个博客基于什么

这个博客基于 **Hugo** 搭建。

- 内容是 Markdown 文件
- 页面由静态文件生成
- 不需要数据库
- 不需要长期维护服务器
- 迁移和备份都比较清楚

部署参考链接：

- 基本上是基于这个部署而来：[2026年了，还有人用博客吗 - 开发调优 - LINUX DO]([https://linux.do/t/topic/1589117](https://linux.do/t/topic/1589117))
- [博客的意义](https://linux.do/t/topic/1625276/19?u=koi_alkaid)

## 它是怎么部署的

这个站点托管在 **GitHub Pages** 上。

大致流程是：

```text
写内容
提交到 GitHub 仓库
GitHub Actions 自动构建 Hugo
部署到 GitHub Pages
```

所以前台看到的是一个纯静态博客。打开速度、备份方式和长期维护成本都比较稳定。

现在的线上地址是：

[https://koialkaid.github.io/blog/](https://koialkaid.github.io/blog/)

## 现在怎么写内容

为了降低写作门槛，接入了 **Pages CMS**：在后台里填写标题、日期、摘要、标签和正文，保存后仍然回写到 GitHub 仓库里的 Markdown 文件。

也就是说，这个博客现在的内容链路是：

```text
Pages CMS
  ↓
Markdown 文件
  ↓
GitHub 仓库
  ↓
GitHub Actions
  ↓
Hugo 静态站点
  ↓
GitHub Pages
```

前台依然是静态博客，CMS 只是帮我少手写一些 front matter。

## 这里会放什么

目前内容主要分成几类：

- `文章`：相对完整一点的整理
- `日记`：短一点的记录和随手想法
- `系列`：围绕一个主题连续写的内容
- `待办`：博客相关的小计划和维护记录

