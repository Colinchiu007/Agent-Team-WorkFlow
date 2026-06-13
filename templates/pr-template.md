<!--
感谢你提交 PR！

本仓库使用强制文档同步门禁。在创建 PR 前，请确认：
1. 已填写"文档同步"部分
2. 已勾选"门禁绕过"（仅紧急情况）
3. 已关联 Issue

未勾选"文档已同步"且无 bypass label 的 PR 将被 CI 红灯拒绝。
-->

## 概述

<!-- 一句话描述这个 PR 做什么 -->

Closes #<Issue-编号>

## 变更类型

- [ ] feat（新功能）
- [ ] fix（Bug 修复）
- [ ] docs（仅文档）
- [ ] refactor（重构，不改功能）
- [ ] test（仅测试）
- [ ] chore（工具/配置/依赖）
- [ ] perf（性能优化）

---

## 🚨 文档同步门禁（硬门禁）

**代码变更必须有对应的文档变更，缺一不可。**

请勾选所有**实际变更**的文档：

- [ ] `docs/PRD.md`（功能列表/数据模型/架构图）
- [ ] `CHANGELOG.md`（`[Unreleased]` 区块）
- [ ] `README.md`（特性列表/快速开始）
- [ ] `docs/AGENTS.md`（路径/约定/测试命令）
- [ ] `docs/ARCH-<feature>.md`（如新增架构）

> 🤖 **AI 自动起草**：CI 会根据 commit history 自动生成 CHANGELOG 草稿到
> `team/inbox/changelog-draft-<本PR号>.md`。请人工确认后合并到 `CHANGELOG.md`。
>
> 草稿路径：`team/inbox/changelog-draft-<本PR号>.md`

**未修改任何文档**（仅在以下情况勾选）：
- [ ] 仅修改注释/格式/测试 → 无需文档同步
- [ ] 仅修改 lockfile（自动生成） → 无需文档同步

---

## 测试

- [ ] 单元测试通过（`pytest tests/ -q` 或 `npm test`）
- [ ] 集成测试通过（如适用）
- [ ] 手动验证通过（截图/录屏附在下方）

---

## CI 检查清单

- [ ] Lint 通过（`ruff check .` / `eslint .`）
- [ ] 类型检查通过（如适用）
- [ ] 构建成功（`npm run build` / `python -m build`）
- [ ] 无 hardcoded secrets（`grep -rn "api_key\|password\|secret" src/`）

---

## CTO Review 检查清单（Reviewer 勾选）

- [ ] 命名规范一致
- [ ] 错误处理完整（无 `except: pass`、无未捕获 Promise）
- [ ] 函数 ≤ 30 行
- [ ] 无安全漏洞（XSS/SQLi/Shell injection）
- [ ] 文档同步清单完整

---

## 🚪 门禁绕过（仅紧急情况）

**仅在以下情况勾选，且必须说明原因：**
- P0 故障 hotfix（需事后补文档）
- 实验性 feature（明确标注"实验性"）

- [ ] **申请绕过门禁**（owner 或 reviewer 加 `bypass-doc-gate` label 后可合并）

**绕过原因**：<必填，例：P0 故障 hotfix，事后 24h 内补文档>

---

## 关联链接

- Issue：#<编号>
- Epic（如有）：#<编号>
- RFC（如有）：`team/RFC/RFC-XXX.md`
- 架构文档（如有）：`docs/ARCH-<feature>.md`

---

## 截图/录屏（如适用）

<!-- 手动验证的视觉证据 -->