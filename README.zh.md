# simp-grill

一套精简、注重成本控制的功能开发 skill 流水线,改编自 [mattpocock/skills](https://github.com/mattpocock/skills)。本地优先:不依赖 issue tracker、无需 setup 初始化、所有约定固化在 skill 内。

## 运行时兼容

本流水线同时支持 Kimi Code 和 OpenCode。`simp-implement`/`simp-implement-tdd` 的工作流保持不变,只有 secondary agent 的调用语法不同:

| 运行时 | 调用方式 | 目标 | 配置方式 |
|---|---|---|---|
| Kimi Code | `Agent` | `subagent_type="coder"` | 执行 `/secondary_model` |
| OpenCode | `Task` | `subagent_type="secondary"` | 配置 `secondary` agent |

Kimi Code:

```text
Agent(subagent_type="coder")
```

省略 `model` 参数,走宿主的 secondary model 默认配置。

OpenCode:

```text
Task(subagent_type="secondary")
```

在 OpenCode 中,`secondary` 是 agent 名称,不是模型 ID。需要在 agent 配置中指定模型。全局配置放在
`~/.config/opencode/agents/secondary.md`,项目级配置放在
`.opencode/agents/secondary.md`:

```markdown
---
description: Implements planned tickets and runs the relevant checks.
mode: subagent
model: opencode-go/deepseek-v4-flash
---

Implement the task described by the parent agent. Read the referenced ticket
and dev doc first, make the required changes, and run the relevant checks.
```

## 流水线

```
/simp-grill            拷问式访谈需求;维护 CONTEXT.md 术语表 + ADR
/simp-to-spec          将对话综合为 spec
                       (始终在 .scratch/ 下落盘快照 PRD)
/simp-to-tickets       将 PRD 拆分为 tracer-bullet tickets,存放于 .scratch/
/simp-implement [--all] 每个 ticket:primary 规划 → secondary 实现 → primary 审查
                       (--all 按依赖串行完成 feature 的全部 tickets)
/simp-implement-tdd [--all] TDD 变体:secondary tester/implementer 对测试先行开发
/simp-code-review      独立的双轴审查,仅手动调用
```

`simp-grill` → `simp-to-spec` 要由用户在**同一个不中断的上下文窗口**内分别手动调用——spec 建立在访谈的思考之上。`simp-to-tickets` 需单独手动调用,可以在同一窗口,也可以在新会话中显式传入 PRD 路径。各 skill 不会自动串联。每次实现调用都在全新上下文中运行,默认只完成一个 ticket;使用 `--all` 时按依赖串行完成 feature 的全部 tickets,然后停止。

## 文档地图

| 文档 | 位置 | 入库 | 性质 | 产出者 |
|---|---|---|---|---|
| 术语表 | `CONTEXT.md` | 是 | 活文档(仅术语) | simp-grill |
| ADR | `docs/adr/` | 是 | 快照——只 supersede,从不修改 | simp-grill / simp-to-spec |
| PRD | `.scratch/<feature>/prd.md` | **否**(gitignore) | 本地长期快照——从不修改 | simp-to-spec |
| tickets | `.scratch/<feature>/issues/` | **否**(gitignore) | 临时;每个 ticket 引用其 PRD | simp-to-tickets |
| dev docs | `.scratch/<feature>/dev-docs/` | **否**(gitignore) | 临时 | simp-implement / simp-implement-tdd |

## 核心规则

- **每次生成 spec 都会落盘。** `/simp-to-spec` 始终写入本地 PRD,不再有 `--docs` 选项,也不需要判断大改小改。
- **所有阶段都设闸门。** 每个 skill 完成自身职责后停止,可以提示下一步命令,但不得调用下一阶段。确认当前产物、回复“继续”或在最初请求中列出完整流程,都不构成跨阶段授权;用户必须在看到当前产物后明确调用下一个 skill。
- **批量实现必须显式授权。** `--all` 授权两个实现 skill 按依赖顺序完成同一 feature 的全部 tickets,每个 ticket 使用 fresh secondary 并单独提交;任何失败或需要用户判断的问题都会停止批次,不授权其他 feature 或 skill。
- **允许独立入口。** 输入充分时可直接调用后续 skill;在新会话独立调用 `simp-to-tickets` 时必须显式传入 PRD 路径。输入不足时停止并说明缺什么,不自动补跑前序阶段。
- **PRD 在本地长期保留。** 只用于本机追溯,不通过 git 共享;清理 `.scratch/` 时仍要保留 PRD。
- **越界后立即停止。** 说明已经产生了什么并保留现场,不自动删除或继续后续工作,等待用户指示。
- **ADR 三条标准缺一不可**:难以逆转、没有上下文会令人费解、存在真实的取舍。否则不记。
- **PRD 是历史快照。** 一旦写入就不再修改,不再维护 PRD 索引或 supersede 机制。代码和测试说明当前行为;PRD 记录各个需求当时的意图。
- **ticket 是脚手架。** 永不入库,并将 PRD 路径传递给实现阶段;tickets 和 dev docs 可清理,PRD 不可清理。
- **两层审查。** `simp-implement` 做轻量的逐 ticket 审查(diff 对验收标准、PRD 一致性);`simp-code-review` 是重型双轴审查——认为值得时手动调用,通常在 feature 收尾。
- **开发跑在 secondary model 上。** primary 只写 dev doc 和审查;secondary 负责读代码、编辑、跑测试。

## 安装

运行安装脚本,可选参数为安装目录:

```sh
./install.sh [目标目录]
```

Windows:

```bat
install.bat [目标目录]
```

Linux/macOS 默认安装到 `~/.agents/skills`,Windows 默认安装到 `%USERPROFILE%\.agents\skills`。脚本会复制所有 skill 目录;重复运行时会覆盖同名文件。

如需改为软链 skill 目录:

```sh
ln -s "$PWD"/simp-* ~/.agents/skills/
```
