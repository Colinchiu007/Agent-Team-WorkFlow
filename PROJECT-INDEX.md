# 🗂️ 项目总览索引

> 记录所有项目编号与名称的对应关系，防止混淆。
> 随时更新，你和我都可以快速查。

---

## 📌 项目速查表

| 项目编号 | 项目名称 | 简称 | 当前阶段 | 详情 |
|---------|----------|------|----------|------|
| PROJECT-001 | 热文改写 Skill 评估 | **热文改写** | 阶段1：立项 | tasks/PROJECT-001-HOT-SKILL.md |
| PROJECT-002 | AI 网页小程序游戏 | **游戏AI** | 阶段1：立项 | tasks/PROJECT-002-GAME-AI.md |
| PROJECT-003 | （待立项） | — | — | — |

---

## 🤝 团队协作机制

**所有项目必须遵循：[team/PROTOCOL.md](./PROTOCOL.md)**

- 4 层机制：L1 决策 → L2 评审 → L3 执行 → L4 监督
- 3 粒度追踪：Epic / Feature / Task
- 工具栈：GitHub Projects + Issues + gh CLI
- 文档门禁：硬门禁 + AI 自动起草 CHANGELOG

详细决策：[RFC-001](./RFC/RFC-001-team-workflow.md) | [PRD](./tasks/PROJECT-009-team-workflow.md) | [架构](./tasks/ARCH-F1-team-workflow.md)

---

## 📝 使用说明

### 你跟我说项目时的用法

| 你说 | 我理解成 |
|------|---------|
| 「热文改写」/ 「PROJECT-001」 | PROJECT-001 热文改写 Skill 评估 |
| 「PROJECT-002」/ 另一个项目的名字 | PROJECT-002 |

### 项目编号命名规则
- **PROJECT-001** ~ **PROJECT-099**：正式项目
- 编号按立项顺序自动分配，不重复

---

## 🚀 如何新建项目

告诉我就行，比如：
> 「帮我立 PROJECT-002，是个新的 xxx 项目」

我会自动：
1. 创建 `team/tasks/PROJECT-00X-[项目名].md`
2. 更新本索引文件
3. 分配团队成员
4. 通知 PM 制定计划

---

## 🔍 快速定位项目文件

```
team/tasks/
├── TASK.md              ← 总任务池（含所有项目汇总）
├── PROJECT-001-HOT-SKILL.md   ← 热文改写项目主档案
└── PROJECT-002-xxx.md        ← 项目2主档案（新建后有）
```

---

*最后更新：2026-06-13 by CEO + COO（新增团队协作机制 v1.0.0）*