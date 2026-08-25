# simp-grill

一套精简、注重成本控制的功能开发 skill 流水线,改编自 [mattpocock/skills](https://github.com/mattpocock/skills)。本地优先:不依赖 issue tracker、无需 setup 初始化、所有约定固化在 skill 内。

## 运行时兼容

本流水线同时支持 Kimi Code 和 OpenCode。`simp-implement` 的工作流保持不变,只有 secondary agent 的调用语法不同:

| 运行时 | 调用方式 | 目标 | 配置方式 |
|---|---|---|---|
| Kimi Code | `Agent` | `subagent_type="coder"` | 执行 `/secondary_model` |
| OpenCode | `Task` | `subagent_type="secondary"` | 配置 `secondary` agent |

Kimi Code:

```text
Agent(subagent_type="coder", model="secondary")
```

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
/simp-to-spec [--docs] 将对话综合为 spec
                       (--docs 时落盘为 docs/prd/ 下的快照 PRD)
/simp-to-tickets       拆分为 tracer-bullet tickets,存放于 .scratch/
/simp-implement        每个 ticket:primary 规划 → secondary tester/implementer 对测试先行开发 → primary 审查
/simp-code-review      独立的双轴审查,仅手动调用
```

`simp-grill` → `simp-to-spec` → `simp-to-tickets` 要在**同一个不中断的上下文窗口**内运行——每一步都建立在前面的思考之上。每个 `/simp-implement` 在全新的上下文中运行,一次一个 ticket。

## 文档地图

| 文档 | 位置 | 入库 | 性质 | 产出者 |
|---|---|---|---|---|
| 术语表 | `CONTEXT.md` | 是 | 活文档(仅术语) | simp-grill |
| ADR | `docs/adr/` | 是 | 快照——只 supersede,从不修改 | simp-grill / simp-to-spec |
| PRD | `docs/prd/`(+ `README.md` 索引) | 是 | 快照——只 supersede,从不修改;索引行承载状态标记 | simp-to-spec --docs |
| tickets | `.scratch/<feature>/issues/` | **否**(gitignore) | 临时 | simp-to-tickets |
| dev docs | `.scratch/<feature>/dev-docs/` | **否**(gitignore) | 临时 | simp-implement |

## 核心规则

- **大改小改由调用入口决定,不靠模型判断。** 需要持久 PRD 就用 `/simp-to-spec --docs`;不需要就用 `/simp-to-spec`,在会话内直接开发。
- **落盘 PRD 必须经过确认。** 如果 `simp-grill` 认为应该生成持久 PRD,必须先说明理由并请求用户明确确认;未确认时使用不带 `--docs` 的 `/simp-to-spec`。
- **ADR 三条标准缺一不可**:难以逆转、没有上下文会令人费解、存在真实的取舍。否则不记。
- **PRD 是快照。** 一旦写入就不再修改。新 feature 在自己的 PRD 里声明 supersede。代码改动不碰 `docs/prd/`——偏离历史 PRD 是预期行为,由下一个覆盖该领域的 PRD supersede。
- **ticket 是脚手架。** 永不入库;意图的持久记录是 PRD。
- **两层审查。** `simp-implement` 做轻量的逐 ticket 审查(diff 对验收标准、PRD 一致性);`simp-code-review` 是重型双轴审查——认为值得时手动调用,通常在 feature 收尾。
- **开发跑在 secondary model 上。** primary 只写 dev doc 和审查;secondary 负责读代码、编辑、跑测试。

## 安装

将 skill 目录软链(或复制)到 agent 的 skills 目录,例如:

```sh
ln -s "$PWD"/simp-* ~/.agents/skills/
```
