---
name: Task
about: 工程师具体动作（写 utils.py、修 bug），关联到 PR
title: "[Task] <具体动作>"
labels: ["task"]
assignees: []
---

## 任务描述

**做什么**：<具体动作，一句话说清>

**为什么做**：<关联的 Feature 是什么？>

---

## 实现要点

<!-- 实现时的注意事项、踩坑记录 -->

- [ ] <要点 1>
- [ ] <要点 2>

---

## 验收标准

- [ ] 代码已提交（关联 PR）
- [ ] 单元测试通过（如适用）
- [ ] 集成测试通过（如适用）
- [ ] 文档同步清单完成

---

## 文档同步清单（硬门禁）

**代码变更必须有对应的文档变更，缺一不可。**

- [ ] `docs/PRD.md` 已更新（如功能/数据模型变更）
- [ ] `CHANGELOG.md` 已添加条目
- [ ] `README.md` 已更新（如用户可见）
- [ ] `docs/AGENTS.md` 已更新（如路径/约定变更）

> 🤖 **AI 自动起草**：CI 会根据 commit message 自动生成 CHANGELOG 草稿到
> `team/inbox/changelog-draft-<PR号>.md`，需人工确认。

---

## 负责人

**Owner**：@<用户名>
**Reviewer**：@<CTO 用户名>
**关联 Feature**：#<Feature-Issue>
**关联 PR**：#<PR-编号（如已创建）>
**预估工时**：<X 小时>

---

## 优先级

- [ ] P0（必须做）
- [ ] P1（应该做）
- [ ] P2（可以做）

---

## 依赖

- 阻塞：#<Task-Issue>
- 阻塞本任务：<如需其他 Task 先完成>