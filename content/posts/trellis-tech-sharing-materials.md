+++
title = 'Trellis 技术分享资料：大模型科普与 AI Coding 框架'
slug = 'trellis-tech-sharing-materials'
date = '2026-04-21T20:30:00'
description = '整理两份关于大模型基础与 Trellis / Harness 落地的技术分享资料，附原帖链接与 PDF 预览。'
tags = [
	'Trellis',
	'AI Coding',
	'LLM',
]
+++
# L站原帖链接

- [https://linux.do/t/topic/2017019](https://linux.do/t/topic/2017019)

# **Trellis-codex app**

- 配置codex的自动演进config设置（进行中）

![](https://oa.feishu.cn/report/v3/api/File?tenantId=6786976427968299009&app_id=cli_9d0208a7d1bbd10c&key=e2d0b881e4cd4962ba920795ffbd3a0f.png)

![](https://oa.feishu.cn/report/v3/api/File?tenantId=6786976427968299009&app_id=cli_9d0208a7d1bbd10c&key=9b1afadc6fa24671ba98fc9ce150502f.png)

- 适配codex app的trellis指令大全+使用说明

![](https://oa.feishu.cn/report/v3/api/File?tenantId=6786976427968299009&app_id=cli_9d0208a7d1bbd10c&key=d9f5d82264e5413ebda1a762603ecbe5.png)

- 初始化指令

![](https://oa.feishu.cn/report/v3/api/File?tenantId=6786976427968299009&app_id=cli_9d0208a7d1bbd10c&key=0b8a2660934f47f7807e9e362f1f37e6.png)

- 如果需求不明确，可以使⽤ /brainstorm 命令进⾏头脑风暴（从Harness Engineering，再到 Trellis 落地中，有详细的使用流程）

# 指令

指令的作用：***告诉 AI：现在进入哪一种工作模式。***

## $start：打开hooks了，不必手动

***让 AI 先读当前项目的上下文，再开始工作。***

**该用的时候：**

- 新开一个旧项目会话，想让 AI 先接上状态
- 从老线程回来，怕 AI 不记得上下文
- AI 明显不知道当前项目情况

## $Brainstorm：需求分析前

***需求不清的时候，不急着写代码，先一起把事情想清楚。***

**该用的时候：**

- 你只知道“大概要做什么”，但还没想清楚
- 一个需求很复杂，不知道怎么拆
- 你担心 AI 一上来就写错方向

## $Before Dev：写/修改代码钱前，是代码规范（单人基本不必考虑）

***开始写代码前，让 AI 先读项目规范。***

**该用的时候：**

- 你准备开始正式改代码
- 尤其是新功能、重构、多文件修改

## $Check：检查代码是否规范（单人不必考虑）

***代码写完后，按项目规范检查一遍。***

它更偏向：

- 代码有没有符合规范
- 有没有明显跑偏
- 有没有和项目已有风格不一致

**该用的时候：**

- 你写完一轮代码
- 想先让 AI 做一次自查

## $Finish Work：判断开发是否完成，可不可以进入测试阶段

***准备结束这轮工作前，做一次收尾总检查。***

**它会关注什么？**

- 这轮改动有没有漏检查
- 是否需要补规范
- 是否有未收尾的问题
- 是否适合进入测试/提交阶段

**该用的时候：**

- 你准备结束当前这轮开发
- 你觉得“差不多做完了”

## $Record Session：开发完成后的状态总结记录

***把这次工作的结果记下来，方便下次继续。***

**什么时候用？**

这是非常重要的一点：

> ***通常在你已经测试过、并且已经提交之后再用。***

也就是：

1. 开发完成
2. 你自己验证/测试
3. 你提交代码
4. 再 record-session

## $Check Cross Layer：检查适不适合改动，做支线任务/修改代码

**它是什么意思？**

一句话：

> ***检查这次改动会不会牵一发动全身。***

---

## **它适合什么场景？**

- 改接口
- 改前后端数据流
- 改数据库结构
- 改跨模块逻辑

## $Update Spec：记录规范

> ***把这次工作里学到的新规范，写回项目规范库。***

---

**它为什么重要？**

因为 Trellis 不只是帮你当下写代码，  
它还想让项目的规则慢慢沉淀下来。

比如你这次发现：

- 某类接口必须这么写
- 某种目录结构以后都统一
- 某种坑以后都要避开

这些都应该写进 .trellis/spec/

---

**什么时候用？**

- 这次开发形成了稳定规则
- 你不希望以后再重复解释
- 你想让 AI 下次自动遵守

## $Break Loop：死循环后重新分析

> ***当你反复修来修去都不对时，停下来做一次根因分析。***

---

**什么时候用？**

- 修 A 坏 B
- 修 B 坏 A
- 连续两三轮都在兜圈子
- 你怀疑自己只是在“止血”，没找到根因

## $Onboard

> ***系统学习这个 Trellis 项目怎么工作。***

---

**什么时候用？**

- 第一次接触某个 Trellis 项目
- 想系统了解 .trellis/ 结构和流程

## $Improve Ut

意思：

> ***帮你补/改单元测试。***

什么时候用：

- 代码改好了，UT 不够
- 想顺手提升测试质量

## $Parallel

> ***把一个大任务拆成多个并行子任务。***

什么时候用：

- 任务很大
- 可以拆成多个互不阻塞的小块

你现在先不用急着学这个。

## $Integrate Skill

意思：

> ***把外部 skill 的经验整合到当前项目的规范里。***

## $Create Command

> ***给这个项目创建新的工作流命令/skill 骨架。***

![image.png](../image.png)

## 资料一：理解大模型，用好 AI Coding

{{< pdf-embed src="posts/1afde82ae916f6b8db1053e46e9cc66efebb9ce1.pdf" title="理解大模型，用好 AI Coding" linktext="↓ 下载 PDF：理解大模型，用好 AI Coding" height="54rem" >}}

## 资料二：从 Harness Engineering，再到 Trellis 落地

{{< pdf-embed src="posts/c3c816033f96ebef98da10e28c912dd6e8894024.pdf" title="从 Harness Engineering，再到 Trellis 落地" linktext="↓ 下载 PDF：从 Harness Engineering，再到 Trellis 落地" height="54rem" >}}