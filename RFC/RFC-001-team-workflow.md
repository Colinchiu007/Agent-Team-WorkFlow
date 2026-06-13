# RFC-001 — 团队协作机制（Team Workflow）

> **状态**：✅ 已接受
> **决策日期**：2026-06-13
> **决策人**：CEO + COO
> **关联**：PROJECT-009 / PM-PRD-v0.1 / ARCH-F1

## 1. 背景

随着项目数从 3 个（PROJECT-001/002/003）增加到 9 个以上（+011/012 等），跨项目的协作问题日益突出：

- **流程靠记忆**：professional-ai-coding-workflow skill 存在但未被强制
- **文档不同步**：CHANGELOG/README/PRD 最后一次性补的现象反复出现
- **决策无记录**："为什么不做 A 方案" 无法追溯
- **进度不透明**：CEO 必须主动询问才知道各项目状态

## 2. 决策内容

### 2.1 机制架构：4 层 + 3 粒度

| 层 | 职责 | 工具 |
|---|------|------|
| L1 决策层 | 战略、资源、优先级 | `team/RFC/*.md` |
| L2 评审层 | RFC/PR/质量门禁 | GitHub PR + `team/checklists/` |
| L3 执行层 | TDD/PR/CI | GitHub Issues + Projects |
| L4 监督层 | 自动化看板 + 异常升级 | GitHub Actions + `team/scripts/` |

**追踪粒度**：Epic / Feature / Task 三层。

### 2.2 工具栈：GitHub 原生

- **看板**：GitHub Projects v2
- **任务**：GitHub Issues
- **CLI**：gh CLI
- **门禁**：GitHub Actions + 本地 pre-commit hook
- **决策记录**：仓库内 `team/RFC/*.md`（ADR 格式）

### 2.3 文档门禁：硬门禁 + AI 起草

- 硬门禁：CI 扫描 PR diff，未同步文档直接 fail
- AI 起草：Conventional Commits → CHANGELOG 草稿，人工确认
- **绕过机制**：owner / reviewer 加 `bypass-doc-gate` label 可合并
- **启用节奏**：第 1 周软提示 → 第 3 周硬门禁

### 2.4 协议文档详细度：完整版（20+ 页）

PROTOCOL.md 包含所有脚本说明、错误处理、FAQ、模板引用。

## 3. 方案对比

### 方案 A：GitHub 原生（本方案）✅

| 维度 | 评估 |
|------|------|
| 成本 | 零 |
| 学习成本 | 低（复用现有 gh CLI 工作流） |
| 集成度 | 高（与现有 Git 工作流无缝） |
| 跨 profile 同步 | ✅ 仓库内文件，不受 profile 隔离影响 |

### 方案 B：Linear + GitHub ❌

| 维度 | 评估 |
|------|------|
| 成本 | 中（$8/人/月） |
| 学习成本 | 中（新增工具） |
| 集成度 | 中（双向同步可能有延迟） |

### 方案 C：Notion + GitHub ❌

| 维度 | 评估 |
|------|------|
| 成本 | 中 |
| 学习成本 | 高（文档协作强但任务追踪弱） |
| 跨 profile 同步 | ❌ Notion 在不同 profile 下独立 |

**选择 A 的核心理由**：
1. 复用现有 gh CLI + Git 工作流，零迁移成本
2. 仓库内文件，受 Git 版本控制，可追溯
3. 不依赖外部服务，离线可用
4. GitHub Projects v2 API 完整，可脚本化

## 4. 实施计划

| 阶段 | 内容 | 工期 | 强制级别 |
|------|------|------|---------|
| A | PROTOCOL.md + 模板（4 件） | 0.5 天 | 软提示 |
| B | 脚本三件套（看板/Issue/门禁） | 1 天 | 软提示 |
| C | GitHub Actions + CHANGELOG 自动起草 | 0.5 天 | **硬门禁** |
| D | PROJECT-011 跑样板验证 | 1 天 | 必做 |
| E | 文档同步 + commit | 0.5 天 | — |

## 5. 后果

### 5.1 正面影响

- ✅ 文档同步从"靠人记"变成"工具挡"
- ✅ 决策可追溯（所有 RFC 进 git 仓库）
- ✅ 进度自动同步（GitHub Projects ↔ Issues）
- ✅ 跨项目统一机制（所有 PROJECT-* 复用）

### 5.2 风险与缓解

| 风险 | 缓解 |
|------|------|
| 流程过严打击开发效率 | 分阶段启用（第 1 周软提示 → 第 3 周硬门禁） |
| gh CLI Windows 配置复杂 | 文档明确 + 验证命令 |
| CHANGELOG 草稿质量差 | 只生成草稿、人工确认 |
| GitHub Projects API 变更 | 脚本封装，对 API 变化透明 |

### 5.3 备选方案

如 GitHub Projects v2 在使用中出现重大限制，回退到方案 B（Linear）。

## 6. 验收标准

- [ ] PROJECT-011 跑通 1 个 feature 全流程（立项 → Done ≤ 1 天）
- [ ] PR 未勾文档同步 → CI 红灯
- [ ] CHANGELOG 草稿偏差 < 10%（人工确认）
- [ ] `gh project view` 能看到 Epic/Feature/Task 三层
- [ ] 所有交付物 git 提交、文档同步
- [ ] `team/PROTOCOL.md` 被 PROJECT-INDEX 引用

## 7. 变更记录

| 日期 | 变更 | 作者 |
|------|------|------|
| 2026-06-13 | 初稿 | COO（agent-coo） |