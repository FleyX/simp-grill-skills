# simp-grill

一套精简、注重成本控制的功能开发 skill 流水线,改编自 [mattpocock/skills](https://github.com/mattpocock/skills)。本地优先:不依赖 issue tracker、无需 setup 初始化、所有约定固化在 skill 内。

## 流水线

```
/simp-grill            拷问式访谈需求;维护 CONTEXT.md 术语表 + ADR
/simp-to-spec [--docs] 将对话综合为 spec
                       (--docs 时落盘为 docs/prd/ 下的活文档 PRD)
/simp-to-tickets       拆分为 tracer-bullet  tickets,存放于 .scratch/
/simp-implement        每个 ticket:primary 规划 → secondary 开发 → primary 审查
/simp-code-review      独立的双轴审查,仅手动调用
```

`simp-grill` → `simp-to-spec` → `simp-to-tickets` 要在**同一个不中断的上下文窗口**内运行——每一步都建立在前面的思考之上。每个 `/simp-implement` 在全新的上下文中运行,一次一个 ticket。

## 文档地图

| 文档 | 位置 | 入库 | 性质 | 产出者 |
|---|---|---|---|---|
| 术语表 | `CONTEXT.md` | 是 | 活文档(仅术语) | simp-grill |
| ADR | `docs/adr/` | 是 | 快照——只 supersede,从不修改 | simp-grill / simp-to-spec |
| PRD | `docs/prd/`(+ `README.md` 索引) | 是 | 活文档——受影响段落与代码同 commit 修正 | simp-to-spec --docs / simp-implement |
| tickets | `.scratch/<feature>/issues/` | **否**(gitignore) | 临时 | simp-to-tickets |
| dev docs | `.scratch/<feature>/dev-docs/` | **否**(gitignore) | 临时 | simp-implement |

## 核心规则

- **大改小改由调用入口决定,不靠模型判断。** 需要持久 PRD 就用 `/simp-to-spec --docs`;不需要就用 `/simp-to-spec`,在会话内直接开发。
- **ADR 三条标准缺一不可**:难以逆转、没有上下文会令人费解、存在真实的取舍。否则不记。
- **PRD 是活文档。** 任何与 PRD 描述行为相悖的改动,都要在同一 commit 内修正受影响段落——包括那些没走 `--docs` 的小改动。
- **ticket 是脚手架。** 永不入库;PRD 中用一行记录该 feature 拆分成了哪些 ticket,足够追溯。
- **两层审查。** `simp-implement` 做轻量的逐 ticket 审查(diff 对验收标准、PRD 同步检查);`simp-code-review` 是重型双轴审查——认为值得时手动调用,通常在 feature 收尾。
- **开发跑在 secondary model 上。** primary 只写 dev doc 和审查;secondary 负责读代码、编辑、跑测试。

## 安装

将 skill 目录软链(或复制)到 agent 的 skills 目录,例如:

```sh
ln -s "$PWD"/simp-* ~/.agents/skills/
```
