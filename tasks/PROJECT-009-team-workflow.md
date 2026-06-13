# PROJECT-009 — 团队协作机制（Team Workflow）

> **定位**：把已有的 professional-ai-coding-workflow（PM-PRD → 架构 → TDD → 文档同步 → commit）从"靠人记得"升级为"靠工具强制"。适用于所有项目。

## 1. 背景与目标

### 1.1 当前痛点

| 痛点 | 表现 | 根因 |
|------|------|------|
| 流程靠记忆 | 用户多次纠正"为什么没按流程走" | 流程在 skill 文档里，未嵌入工具 |
| 文档滞后 | CHANGELOG/README/PRD 最后一次性补 | 没有自动化门禁 |
| 决策无记录 | "为什么不做 A 方案？"无法追溯 | 没有 ADR/RFC |
| 进度不透明 | 多项目并行时各自埋头干 | 没有跨项目看板 |
| 监督靠人盯 | CEO 自己检查文档完整性 | 没有自动化检查 |

### 1.2 目标

- **可强制**：违反流程 → 工具直接拒绝（CI 红 / PR 模板硬要求）
- **可追溯**：所有决策、变更、文档同步都有记录
- **可监督**：自动化看板 + 异常升级，不依赖 CEO 主动检查
- **跨项目一致**：所有 PROJECT-* 复用同一套机制

## 2. 4 层机制设计

```
┌─────────────────────────────────────────┐
│ L1 决策层（CEO / COO）                  │  → 战略、资源、优先级
├─────────────────────────────────────────┤
│ L2 评审层（PM + CTO + QA）              │  → RFC 签字、质量门禁
├─────────────────────────────────────────┤
│ L3 执行层（开发工程师）                  │  → TDD、PR、CI
├─────────────────────────────────────────┤
│ L4 监督层（自动化 + 看板 + 告警）         │  → 实时反馈、自动升级
```

| 层 | 工具载体 | 自动化程度 |
|---|---------|----------|
| L1 | `team/RFC/`（决策记录） + `team/decisions.log` | 半自动（COO 录入） |
| L2 | GitHub PR Review + `team/CHECKLISTS/` | 半自动 |
| L3 | GitHub Issues + GitHub Projects | 自动（看板同步） |
| L4 | GitHub Actions + `team/scripts/` | 全自动 |

## 3. Epic / Feature / Task 三层粒度

| 层级 | 含义 | Issue 模板字段 | 数量约束 |
|------|------|--------------|---------|
| **Epic** | 战略性目标（如"v1.0 发布"） | milestone + 多 Feature 链接 | 每项目 ≤ 5 个活跃 |
| **Feature** | 用户可感知的功能（如"加导出 PDF"） | RFC 链接 + 验收标准 + owner | 每 Epic ≤ 10 个 |
| **Task** | 工程师具体动作（如"写 utils.py"） | PR 链接 + 工时估算 | 每 Feature ≤ 8 个 |

**看板列定义**：
```
Backlog → RFC 评审 → Ready → In Progress → Review → Done → Released
```

## 4. 工具栈决策

| 维度 | 选择 | 理由 |
|------|------|------|
| 看板 | **GitHub Projects v2** | 零成本、与 Issue 双向同步、API 完整 |
| 任务管理 | **GitHub Issues** | 已有、跨项目统一 |
| 命令行 | **gh CLI** | Windows 原生支持、JSON 输出可脚本化 |
| 门禁 | **GitHub Actions + 本地 pre-commit hook** | 双重保险 |
| 决策记录 | **`team/RFC/*.md`**（ADR 格式） | 不依赖外部服务、可 git 追踪 |
| 跨项目索引 | **`team/PROJECT-INDEX.md` + `PROJECT-REGISTRY.md`** | 已有、强化 |

**评估过的方案**：
- ~~Linear + GitHub~~：成本高、与现有 gh CLI 工作流割裂
- ~~Notion + GitHub~~：文档协作强但任务追踪弱、跨 profile 同步问题
- ✅ **GitHub Projects + Issues + gh CLI**：复用现有生态、学习成本最低

## 5. 交付物清单

| # | 交付物 | 路径 | 类型 | 优先级 |
|---|--------|------|------|--------|
| D1 | 团队协作协议文档 | `team/PROTOCOL.md` | 文档 | P0 |
| D2 | RFC 模板（含 ADR 字段） | `team/templates/RFC-template.md` | 模板 | P0 |
| D3 | Issue 模板（Epic/Feature/Task） | `team/templates/issue-*.md` | 模板 | P0 |
| D4 | PR 模板（文档同步硬门禁） | `team/templates/pr-template.md` | 模板 | P0 |
| D5 | 看板初始化脚本 | `team/scripts/init-kanban.sh` | 脚本 | P0 |
| D6 | Issue 创建 CLI 封装 | `team/scripts/create-issue.sh` | 脚本 | P0 |
| D7 | 文档同步门禁脚本 | `team/scripts/check-docs-sync.sh` | 脚本 | P0 |
| D8 | CHANGELOG 自动起草脚本 | `team/scripts/draft-changelog.sh` | 脚本 | P1 |
| D9 | GitHub Actions 工作流 | `.github/workflows/doc-gate.yml` | CI | P0 |
| D10 | 监督层看板导出 | `team/scripts/dashboard-export.sh` | 脚本 | P2 |

## 6. 功能依赖图

```
D1 (协议文档)  ──┐
                  ├──→ D5 (看板初始化脚本) ──→ D6 (Issue CLI)
D2 (RFC 模板)  ──┤                                    │
                  ├──→ D3 (Issue 模板) ───────────────┤
                  │                                    │
D4 (PR 模板)  ──┴──→ D7 (文档门禁) ──→ D8 (CHANGELOG 起草)
                          │
                          └──→ D9 (GitHub Actions)
                                                     │
                                          D10 (看板导出) ── P2 后续
```

## 7. 工期估算

| 阶段 | 内容 | 工期 |
|------|------|------|
| **阶段 A** | D1-D4（协议+模板） | 0.5 天 |
| **阶段 B** | D5-D7（脚本三件套） | 1 天 |
| **阶段 C** | D8-D9（自动化层） | 0.5 天 |
| **阶段 D** | 跑通样板（PROJECT-011） | 1 天 |
| **阶段 E** | 文档同步 + commit | 0.5 天 |
| **总计** | | **3.5 天** |

## 8. 验收标准

- [ ] 在 PROJECT-011 上创建一个 Feature，从"立项 → Done" 全程不超过 1 天
- [ ] PR 未勾选文档同步 checkbox → CI 红灯
- [ ] CHANGELOG 自动生成草稿，偏差 < 10%（人工确认）
- [ ] `gh project view` 能看到 Epic/Feature/Task 三层结构
- [ ] 所有交付物已 git 提交、文档同步
- [ ] `team/PROTOCOL.md` 被 PROJECT-INDEX 引用

## 9. 不在范围

- ❌ Linear / Notion 集成
- ❌ Slack / 飞书通知（用 GitHub 原生通知即可）
- ❌ 自动化代码评审（保留人工 CTO Review）
- ❌ 跨组织权限管理（单人项目，无需 RBAC）

## 10. 风险与缓解

| 风险 | 概率 | 影响 | 缓解 |
|------|------|------|------|
| GitHub Projects API 变更 | 低 | 高 | 用 gh CLI 封装，对 API 变化透明 |
| Windows gh CLI 配置复杂 | 中 | 中 | 写好 .md 文档 + 验证命令 |
| 流程过严打击开发效率 | 中 | 中 | 软提示 → 硬门禁 分阶段启用 |
| CHANGELOG 自动起草不准 | 高 | 低 | 只生成草稿、人工最终确认 |

---

**状态**：草案 v0.1 — 等待 CEO 签字
**作者**：COO（agent-coo）
**日期**：2026-06-13