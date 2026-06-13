# 🤝 团队项目交付协作协议（Team Workflow Protocol）

> **版本**: v1.0.0
> **生效日期**: 2026-06-13
> **决策记录**: [RFC-001](./RFC/RFC-001-team-workflow.md)
> **关联协议**:
> - [通信协议](./protocols/comm.md)（Agent 间通信）
> - [互评协议](./protocols/CROSS-EVAL.md)（跨角色互评）

---

## 📑 目录

1. [协议概述](#1-协议概述)
2. [4 层 + 3 粒度机制](#2-4-层--3-粒度机制)
3. [工具栈与目录结构](#3-工具栈与目录结构)
4. [完整工作流（CEO → Agent → CEO）](#4-完整工作流)
5. [模板与脚本说明](#5-模板与脚本说明)
6. [硬门禁与绕过机制](#6-硬门禁与绕过机制)
7. [角色职责矩阵](#7-角色职责矩阵)
8. [监督层（看板 + 异常升级）](#8-监督层)
9. [启用节奏](#9-启用节奏)
10. [FAQ](#10-faq)
11. [错误处理与故障排查](#11-错误处理与故障排查)
12. [附录：模板索引](#12-附录)

---

## 1. 协议概述

### 1.1 为什么需要这个协议

**问题**：
- 用户多次纠正"为什么没按流程走"
- 文档（CHANGELOG / README / PRD）最后一次性补
- 决策"为什么不做 A 方案"无法追溯
- 多项目并行时进度不透明

**解决方案**：把 `professional-ai-coding-workflow` skill 从"靠人记得"升级为"靠工具强制"。

### 1.2 协议范围

**适用**：所有 PROJECT-* 项目（001/002/003/011/012 等）

**不适用**：
- 个人小工具（无文档要求）
- 一次性脚本（无后续维护）
- 实验性 PoC（明确标注"实验性"）

### 1.3 与现有协议的关系

| 协议 | 范围 | 何时读 |
|------|------|--------|
| **本协议**（PROTOCOL.md） | 项目交付、Issue/PR/看板/门禁 | 开始新功能前 |
| [通信协议](./protocols/comm.md) | Agent 间消息格式、优先级 | 跨角色通信时 |
| [互评协议](./protocols/CROSS-EVAL.md) | 周度互评、冲突处理 | 周报/争议时 |
| [skill: professional-ai-coding-workflow](../../hermes-home/profiles/coo/skills/software-development/professional-ai-coding-workflow/SKILL.md) | 单项目开发完整 SOP | 启动新项目时 |

**核心关系**：本协议把 skill 中描述的 SOP **工具化**。

---

## 2. 4 层 + 3 粒度机制

### 2.1 4 层职责划分

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

#### L1 决策层

**职责**：
- 战略方向（做不做这个 Epic）
- 资源分配（优先级 P0/P1/P2/P3）
- 跨项目冲突裁定
- 重大 RFC 签字

**工具**：
- `team/RFC/RFC-XXX-*.md`（决策记录）
- `team/decisions/YYYY-MM-DD-*.md`（时间线）

**签字规则**：
- Epic 创建 → CEO 拍板（"做不做"）
- 重大技术方案 → CTO + CEO 双签
- 跨项目冲突 → COO 协调，CEO 最终裁定

#### L2 评审层

**职责**：
- RFC 评审（方案对比 + 决策）
- PR Review（代码质量 + 文档同步）
- 质量门禁（测试覆盖率、Lint、安全扫描）

**工具**：
- `team/checklists/pr-review.md`
- GitHub PR Review

**评审维度**：详见 §7 角色职责矩阵。

#### L3 执行层

**职责**：
- 创建 Feature/Task Issue
- TDD 开发（Red → Green → Refactor）
- 提交 PR（关联 Issue，勾选文档同步）
- 响应 Reviewer 反馈

**工具**：
- GitHub Issues + Projects
- `team/scripts/create-issue.sh`

#### L4 监督层

**职责**：
- 自动化看板同步
- Stale Issue 检测
- 异常升级（卡住 > 7 天自动告警）
- 周报自动生成

**工具**：
- `team/scripts/dashboard-export.sh`
- GitHub Actions cron

### 2.2 Epic / Feature / Task 三粒度

| 层级 | 含义 | Issue 模板 | 数量约束 |
|------|------|----------|---------|
| **Epic** | 战略性目标（如"v1.0 发布"） | `team/templates/issue-epic.md` | 每项目 ≤ 5 个活跃 |
| **Feature** | 用户可感知的功能（如"导出 PDF"） | `team/templates/issue-feature.md` | 每 Epic ≤ 10 个 |
| **Task** | 工程师具体动作（如"写 utils.py"） | `team/templates/issue-task.md` | 每 Feature ≤ 8 个 |

**看板状态机**：
```
Backlog → RFC 评审 → Ready → In Progress → Review → Done → Released
   ↑________|         ↑__________________________|
   （踢回 Backlog）    （踢回 Ready，重新打开）
```

**关联关系**：
- Epic 包含 N 个 Feature（通过 Issue 引用 `关联 Epic: #X`）
- Feature 包含 N 个 Task
- Task 关联到 PR（PR body 写 `Closes #Y`）

---

## 3. 工具栈与目录结构

### 3.1 工具决策

| 工具 | 选择 | 拒绝的方案 | 决策理由 |
|------|------|-----------|---------|
| 看板 | **GitHub Projects v2** | Linear | 零成本、API 完整、跨 profile 同步 |
| 任务管理 | **GitHub Issues** | Jira/Notion DB | 已有、与 PR 无缝关联 |
| CLI | **gh CLI** | hub/curl | Windows 原生支持、JSON 输出可脚本化 |
| CI | **GitHub Actions** | Jenkins/CircleCI | 与 GitHub Issue/PR 深度集成 |
| 决策记录 | **仓库内 `team/RFC/`** | Confluence/Notion | git 版本控制、零依赖 |

### 3.2 目录结构

```
Projects/                              ← 工作区根目录
├── team/                              ← 跨项目协作基础设施
│   ├── PROTOCOL.md                    ← 本文件（团队交付协议）
│   ├── PROJECT-INDEX.md               ← 项目索引
│   ├── PROJECT-REGISTRY.md            ← 项目注册表
│   ├── README.md                      ← 团队架构说明
│   ├── templates/                     ← 模板
│   │   ├── RFC-template.md
│   │   ├── issue-epic.md
│   │   ├── issue-feature.md
│   │   ├── issue-task.md
│   │   └── pr-template.md
│   ├── RFC/                           ← 决策记录
│   │   └── RFC-XXX-*.md
│   ├── decisions/                     ← 决策时间线
│   │   └── YYYY-MM-DD-*.md
│   ├── checklists/                    ← 评审清单
│   │   ├── pr-review.md
│   │   └── release-gate.md
│   ├── scripts/                       ← 工具脚本
│   │   ├── init-kanban.sh
│   │   ├── create-issue.sh
│   │   ├── check-docs-sync.sh
│   │   ├── draft-changelog.sh
│   │   ├── dashboard-export.sh
│   │   └── doc-gate.yml
│   ├── inbox/                         ← 异步收件箱
│   ├── reports/                       ← 报告
│   ├── protocols/                     ← 其他协议
│   │   ├── comm.md
│   │   └── CROSS-EVAL.md
│   ├── roles/                         ← 角色定义
│   ├── tasks/                         ← 任务档案
│   └── ...
├── PROJECT-XXX/                       ← 各项目目录
│   ├── .github/
│   │   ├── workflows/
│   │   │   └── doc-gate.yml           ← 文档门禁（从 team/scripts 复制）
│   │   └── ISSUE_TEMPLATE/            ← 可选：项目级模板
│   ├── docs/
│   ├── src/
│   └── ...
```

---

## 4. 完整工作流（CEO → Agent → CEO）

### 4.1 阶段 1：Epic 立项（L1 决策）

**触发**：CEO/COO 提出新战略目标

**步骤**：
1. COO 创建 Epic Issue：
   ```bash
   ./team/scripts/create-issue.sh epic "v1.0 发布" --milestone=v1.0
   ```
2. 填写 Epic Issue body（使用 `team/templates/issue-epic.md`）
3. CEO Review Epic，签字"做 / 不做 / 改"
4. Epic 进入 "RFC 评审" 状态

**产出物**：
- GitHub Issue #N（Epic）
- `team/decisions/YYYY-MM-DD-*.md`（重大决策）

### 4.2 阶段 2：Feature 拆分（L1+L2 评审）

**触发**：Epic 进入 Ready 状态

**步骤**：
1. PM 拆分 Epic 为 N 个 Feature Issue：
   ```bash
   for feature in "导出 PDF" "导入 CSV" "搜索增强"; do
     ./team/scripts/create-issue.sh feature "$feature" --epic=$EPIC_NUM
   done
   ```
2. 对每个 Feature 写 RFC（如需重大决策）：
   ```bash
   cp team/templates/RFC-template.md team/RFC/RFC-002-$feature.md
   # 编辑 RFC，方案对比 + 决策
   ```
3. CEO + CTO 双签 RFC

**产出物**：
- N 个 Feature Issues
- M 个 RFC 文件

### 4.3 阶段 3：Task 分解（L2 评审）

**触发**：Feature 签字通过

**步骤**：
1. 工程师把 Feature 拆分为 Task（≤ 4 小时一个）：
   ```bash
   ./team/scripts/create-issue.sh task "实现 utils.py" --feature=$FEATURE_NUM
   ./team/scripts/create-issue.sh task "写单元测试" --feature=$FEATURE_NUM
   ./team/scripts/create-issue.sh task "更新 CHANGELOG" --feature=$FEATURE_NUM
   ```
2. 关联 Task 到当前 Sprint
3. Task 进入 Ready 状态

**产出物**：
- N 个 Task Issues（每个关联到 Feature）

### 4.4 阶段 4：TDD 开发（L3 执行）

**触发**：Task 状态切到 In Progress

**步骤**（专业 AI Coding Workflow 完整版）：
1. 切分支：`git checkout -b feat/issue-$TASK_NUM`
2. **TDD RED**：先写测试，验证失败
3. **TDD GREEN**：写实现，让测试通过
4. **TDD REFACTOR**：清理代码（保持测试绿）
5. 提交（**Conventional Commits**）：
   ```bash
   git commit -m "feat(export): add PDF generation"
   git commit -m "test(export): add PDF unit tests"
   git commit -m "docs: update CHANGELOG with PDF export"
   ```

**关键约定**：
- **每次提交必须有 Conventional Commits 前缀**（feat/fix/docs/refactor/test/chore）
- **代码 + 测试 + 文档同步提交**（不允许分多次 PR）
- **不允许直接 commit 到 main**（必须经过 PR）

### 4.5 阶段 5：PR 创建（L3 → L2 评审）

**触发**：Task 完成，本地测试全绿

**步骤**：
1. 推送分支：
   ```bash
   git push -u origin feat/issue-$TASK_NUM
   ```
2. 创建 PR（使用 `team/templates/pr-template.md`）：
   ```bash
   gh pr create --fill  # 自动用 git commit message 填充
   ```
3. **关键**：在 PR body 中勾选"文档同步" checkbox
4. 关联 Issue：`Closes #$TASK_NUM`

**自动触发**：
- GitHub Actions 跑 `check-docs-sync.sh`（硬门禁）
- `draft-changelog.sh` 生成草稿到 `team/inbox/`

### 4.6 阶段 6：CI 门禁（L4 监督）

**触发**：PR 创建/更新

**GitHub Actions 流程**：
```yaml
# .github/workflows/doc-gate.yml
1. 检出代码（fetch-depth: 0 看完整 diff）
2. 运行 check-docs-sync.sh（硬门禁）
3. 通过 → 运行 draft-changelog.sh（生成草稿）
4. 上传草稿 artifact
```

**失败处理**：
- ❌ 文档同步 checkbox 未勾 → 红灯，要求修改
- ❌ 代码变更但无文档 → 红灯，要求补充文档
- ❌ 测试失败 → 红灯，要求修复
- ✅ 全部通过 → 进入 Review

### 4.7 阶段 7：PR Review（L2 评审）

**触发**：CI 全绿

**Reviewer 责任**（CTO 或指定 Reviewer）：
1. 按 `team/checklists/pr-review.md` 逐项检查
2. 在 PR 评论中按 `Critical / Major / Minor` 分类问题
3. 要求修改 → PR 状态切回 `In Progress`
4. 通过 → Approve → 合并

**合并命令**：
```bash
# 常规合并
gh pr merge <PR号> --squash --delete-branch

# 绕过门禁合并（需先加 label）
gh pr edit <PR号> --add-label "bypass-doc-gate"
gh pr merge <PR号> --squash --delete-branch
```

### 4.8 阶段 8：合并后同步（L4 监督）

**触发**：PR merge

**自动动作**：
1. GitHub 自动关闭关联 Issue（Task）
2. Issue 状态自动从 `In Progress` → `Done`（看板拖动）
3. Feature 状态自动更新（如所有 Task Done → Feature Ready for Done）
4. Epic 状态自动更新（如所有 Feature Done → Epic Done）

**人工动作**：
1. 确认 `team/inbox/changelog-draft-*.md` 内容
2. 合并到 `CHANGELOG.md` 的 `[Unreleased]` 区块
3. 删除 inbox 中的草稿文件
4. 更新 `PROJECT-INDEX.md`（如项目状态变更）

---

## 5. 模板与脚本说明

### 5.1 模板索引

| 模板 | 路径 | 何时用 |
|------|------|--------|
| RFC 模板 | `team/templates/RFC-template.md` | 重大决策、方案对比 |
| Epic Issue | `team/templates/issue-epic.md` | 战略目标 |
| Feature Issue | `team/templates/issue-feature.md` | 用户可感知功能 |
| Task Issue | `team/templates/issue-task.md` | 工程师具体动作 |
| PR 模板 | `team/templates/pr-template.md` | 每个 PR |
| PR Review 清单 | `team/checklists/pr-review.md` | CTO Review PR 时 |

### 5.2 脚本索引

| 脚本 | 用途 | 用法 |
|------|------|------|
| `init-kanban.sh` | 初始化项目看板 | `./init-kanban.sh "PROJECT-XXX v1.0"` |
| `create-issue.sh` | 创建 Issue 并关联看板 | `./create-issue.sh <type> "<title>" --epic=N` |
| `check-docs-sync.sh` | 检查 PR 文档同步（CI 用） | `./check-docs-sync.sh --base=main --head=feat/xxx` |
| `draft-changelog.sh` | 自动起草 CHANGELOG | `./draft-changelog.sh --output=path` |
| `dashboard-export.sh` | 导出看板状态为 Markdown | `./dashboard-export.sh --project=<url> --output=<path>` |

### 5.3 脚本使用示例

**创建 Epic**：
```bash
./team/scripts/create-issue.sh epic "v0.8.0 发布" \
  --project=https://github.com/users/me/projects/1 \
  --milestone=v0.8.0
```

**创建 Feature（关联 Epic）**：
```bash
./team/scripts/create-issue.sh feature "导出 PDF" \
  --epic=42 \
  --milestone=v0.8.0
```

**创建 Task（关联 Feature）**：
```bash
./team/scripts/create-issue.sh task "实现 pdf_writer.py" \
  --feature=43 \
  --assignee=me
```

**本地验证文档同步**：
```bash
bash team/scripts/check-docs-sync.sh \
  --base=main \
  --head=feat/pdf-export
```

**生成 CHANGELOG 草稿**：
```bash
bash team/scripts/draft-changelog.sh \
  --output=team/inbox/changelog-draft-pr-44.md \
  --since-tag=v0.7.0
```

---

## 6. 硬门禁与绕过机制

### 6.1 硬门禁列表

| 门禁 | 触发 | 失败后果 |
|------|------|---------|
| **文档同步** | `check-docs-sync.sh` 红灯 | PR 不可合并 |
| **测试通过** | `pytest` / `npm test` 失败 | PR 不可合并 |
| **Lint 通过** | `ruff` / `eslint` 失败 | PR 不可合并 |
| **无硬编码密钥** | `grep` 扫描发现 | PR 不可合并 |
| **Conventional Commits** | commit msg 不规范 | Warning（不阻塞） |

### 6.2 绕过流程

**何时可绕过**：
- P0 故障 hotfix（事后 24h 内补文档）
- 实验性 feature（明确标注"实验性"）

**绕过步骤**：
1. 在 PR body 勾选"申请绕过门禁" + 填写原因
2. Owner 或 Reviewer 加 `bypass-doc-gate` label：
   ```bash
   gh pr edit <PR号> --add-label "bypass-doc-gate"
   ```
3. 合并后，创建 follow-up Issue 跟踪补文档

**滥用后果**：
- 单个 PR 绕过 → 警告
- 月度绕过 > 3 次 → 升级到 CTO 复盘

### 6.3 bypass-doc-gate label 设置

**首次使用需创建**：
1. GitHub 仓库 → Issues → Labels → New label
2. Name: `bypass-doc-gate`
3. Description: `紧急情况下绕过文档同步门禁，需事后补文档`
4. Color: `#d93f0b`（红色警示）

---

## 7. 角色职责矩阵

### 7.1 跨角色评价矩阵

```
                        ↓ 被评价方
评价方 →    CEO          PM           CTO          COO
-----------------------------------------------------------------
CEO 评价    —（自评）   任务分解      技术方案      商业价值
PM 评价    战略清晰度   —（自评）     工时估算      运营契合度
CTO 评价    资源决策     PRD 完整度    —（自评）     数据指标
COO 评价    优先级       排期合理性    可发布性      —（自评）
```

### 7.2 决策权分层

| 决策类型 | 决策人 | 工具 |
|---------|--------|------|
| 项目立项（做不做） | CEO | Epic Issue + RFC |
| 技术方案选型 | CTO | Feature RFC + 签字 |
| 优先级（P0/P1/P2） | COO + CEO 协商 | Issue label |
| 资源分配（人/钱） | CEO | `team/decisions/` |
| 异常处理（hotfix） | CTO（事后告知 CEO） | bypass label + follow-up Issue |
| 跨项目冲突 | COO 协调，CEO 裁定 | 通信协议 escalation |

### 7.3 评审职责

| 评审项 | 责任角色 | 输出 |
|--------|---------|------|
| RFC 方案对比 | PM + CTO | RFC 文件签字 |
| PR 代码质量 | CTO（指定 Reviewer） | PR 评论 + Approve |
| 文档完整性 | 全体（自查） + COO（审计） | Doc Audit 报告 |
| 测试覆盖率 | QA | 测试报告 |
| 发布就绪 | COO | Release gate 清单 |

---

## 8. 监督层

### 8.1 自动看板同步

**触发**：每个 PR merge 后

**GitHub Actions 自动**：
- 关闭关联 Issue → Issue 状态自动更新
- 看板上拖动到 `Done` 列（需手动）

**手动看板更新**：
```bash
# 导出当前状态
./team/scripts/dashboard-export.sh \
  --project=https://github.com/users/me/projects/1 \
  --output=team/reports/dashboard-$(date +%Y-%m-%d).md
```

### 8.2 Stale Issue 检测

**规则**：Task 在 `In Progress` 状态 > 7 天 → 标记 stale + 评论

**脚本**（P2 功能，后续实现）：
```yaml
# .github/workflows/stale.yml
on:
  schedule:
    - cron: '0 9 * * *'  # 每天 9:00
jobs:
  stale:
    runs-on: ubuntu-latest
    steps:
      - name: 标记 stale issues
        uses: actions/stale@v8
        with:
          days-before-stale: 7
          days-before-close: 14
          stale-issue-label: 'stale'
          exempt-issue-labels: 'pinned,security'
```

### 8.3 异常升级流程

```
Task 卡在 In Progress > 7 天
   ↓ (Stale Bot 自动标记)
owner 收到提醒（GitHub Notifications）
   ↓
3 天内未响应
   ↓
自动加 label "needs-cto-attention"
   ↓
CTO 介入决策（继续 / 重新分配 / 取消）
```

---

## 9. 启用节奏

### 9.1 第 1 周：基础设施（已交付）

- ✅ PROTOCOL.md（本文件）
- ✅ 5 个模板（RFC/Epic/Feature/Task/PR）
- ✅ 5 个脚本（看板/Issue/门禁/草稿/导出）
- ✅ RFC-001 决策记录

**状态**：软提示（推荐使用，不强制）

### 9.2 第 2 周：模板落地

**动作**：
- [ ] 每个 PROJECT-* 仓库创建 `.github/ISSUE_TEMPLATE/` 引用 `team/templates/`
- [ ] 每个 PROJECT-* 仓库创建 `.github/workflows/doc-gate.yml`（从 `team/scripts/doc-gate.yml` 复制）
- [ ] 在 PROJECT-011 上跑 1 个 feature 全流程（样板验证）

**状态**：硬门禁 + bypass label

### 9.3 第 3 周：全面启用

**动作**：
- [ ] 所有新 PR 必须经过门禁
- [ ] 每周 Dashboard 自动导出到 `team/reports/`
- [ ] Stale 检测启用

**状态**：硬门禁，无 bypass 提醒

### 9.4 第 4 周+：优化

- [ ] 收集用户反馈，调整门禁严格度
- [ ] 评估是否需要更多自动化（如 release automation）

---

## 10. FAQ

### Q1: 怎么快速知道当前在哪个阶段？

A: 看 PR 状态：
- `Draft` → 还在开发
- `Open` + CI 绿 → 等待 Review
- `Open` + CI 红 → 修复门禁
- `Merged` → 已完成，看自动关闭的 Issue

### Q2: Feature Issue 一定要 RFC 吗？

A: 不一定。RFC 用于**重大决策**（方案选型、架构变更、跨项目影响）。简单的 Feature 可以直接在 Issue body 写技术方案。

**触发 RFC 的场景**：
- 引入新依赖（如新框架、新数据库）
- 架构变更（如改成分布式）
- 跨项目影响（如 PROJECT-001 影响 PROJECT-003）
- 不可逆决策（如删除旧 API）

### Q3: PR 没勾文档同步但我加了 bypass label，会被拒吗？

A: 不会。bypass label 优先级高于门禁，但**事后必须补文档**：
1. 创建 follow-up Issue 跟踪
2. 24h 内（hotfix）/ 7d 内（实验性）补完文档
3. CTO 周会复盘 bypass 使用情况

### Q4: 一个 Epic 可以跨多个 Milestone 吗？

A: 不推荐。Epic 应绑定单个 Milestone。如果实际跨度超出，**拆分为多个 Epic**。

### Q5: Task 估时 > 4 小时怎么办？

A: **必须拆分**。Task 粒度上限是 4 小时，目的是：
- 进度可追踪（不会出现 1 个 Task 卡 3 天）
- PR 可管理（diff 不超过 500 行）
- 风险可暴露（早暴露比晚暴露好）

### Q6: 我的项目不用 GitHub，怎么用这套机制？

A: 当前协议绑定 GitHub。其他平台需要做适配：
- GitLab：替换 `gh` 为 `glab`，Issues/Projects 概念相同
- Gitee：API 类似 GitHub，但 CLI 不同
- 暂不支持 Jira/Linear（如需支持，单独 RFC）

### Q7: 怎么拒绝 CEO 的 Epic？

A: 在 Epic Issue 中评论"风险点 + 替代方案"。如果分歧大：
1. 升级到 RFC（写正式决策记录）
2. 跨角色互评（按 CROSS-EVAL 协议）
3. 最终 CEO 裁定，记录在 `team/decisions/`

### Q8: bypass-doc-gate label 被滥用怎么办？

A: 月度统计 + 升级：
1. 月度 COO 报告统计 bypass 次数
2. > 3 次/月 → 该 owner 进入"待改进"清单
3. > 5 次/月 → CTO 介入，重新培训

### Q9: 我可以跳过 PROTOCOL 直接用 skill 吗？

A: 不推荐。skill 是"工作流"，本协议是"工作流的工具化"。两者关系：
- skill：告诉你**该做什么**（PM-PRD → 架构 → TDD → 文档同步）
- 协议：通过工具**强制执行** skill 中的步骤

跳协议 = 流程靠记忆，容易遗漏。

### Q10: 协议什么时候更新？

A: 通过 RFC 流程更新：
1. 任何 Agent 可提议变更
2. CTO 评估技术影响
3. CEO 签字
4. 更新本文件 + 创建新 RFC

---

## 11. 错误处理与故障排查

### 11.1 常见错误

#### 错误 1: `gh: command not found`

**原因**：gh CLI 未安装

**解决**：
```bash
# Windows (winget)
winget install GitHub.CLI

# macOS
brew install gh

# Linux
sudo apt install gh

# 验证
gh --version
```

#### 错误 2: `gh auth status` 提示未登录

**解决**：
```bash
gh auth login
# 按提示选择 GitHub.com → HTTPS → 浏览器登录
```

#### 错误 3: `init-kanban.sh` 失败，提示 Project 已存在

**原因**：幂等设计，Project 已存在会跳过

**解决**：检查输出，如果 Project URL 已显示 → 成功，跳过即可

#### 错误 4: `check-docs-sync.sh` 失败但 PR 看起来有文档

**原因**：PR body 格式不规范，checkbox 未被识别

**解决**：
1. 检查 PR body 中 checkbox 格式：` - [x] docs/PRD.md`（注意空格）
2. 重新编辑 PR body，确保格式正确
3. 重新 push 触发 CI

#### 错误 5: `draft-changelog.sh` 生成空文件

**原因**：commit 不符合 Conventional Commits 规范

**解决**：
1. 检查 commit：`git log --oneline -10`
2. 必须以 `feat:` / `fix:` / `docs:` / `refactor:` / `test:` / `chore:` 开头
3. 修改历史：`git rebase -i HEAD~5` 重写 commit message

#### 错误 6: Windows bash 中 `declare -A` 报错

**原因**：MSYS bash 不支持关联数组

**解决**：本协议脚本已避免使用关联数组（用普通变量替代）。如自己编写脚本，参考 `draft-changelog.sh` 的实现。

#### 错误 7: `gh project item-add` 失败（GH CLI < 2.21）

**原因**：Project v2 自动化需要 gh CLI 2.21+

**解决**：
```bash
# 更新 gh CLI
gh version  # 检查当前版本
# 下载最新版：https://cli.github.com/
```

#### 错误 8: GitHub Actions 跑 check-docs-sync.sh 时 `git diff` 为空

**原因**：默认 `fetch-depth: 1` 只拉最后一个 commit，看不到 base diff

**解决**：在 workflow 中显式设置：
```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0  # 关键！
```

### 11.2 故障排查流程

```
问题发生
   ↓
1. 看错误信息（exit code + stderr）
   ↓
2. 对照本节"常见错误"查找匹配项
   ↓
3. 如果未匹配 → 本地复现
   ↓
4. 本地复现 → 修复 → 提交修复 commit
   ↓
5. 重新触发 CI
   ↓
6. 仍然失败 → 升级到 CTO
```

### 11.3 应急通道

**如果机制本身故障**：
1. CEO 临时关闭硬门禁（在 workflow 中加 `if: false`）
2. 创建 P0 Issue 跟踪修复
3. 修复完成后恢复门禁

**应急命令**：
```bash
# 临时禁用 doc-gate workflow
gh workflow disable doc-gate.yml

# 重新启用
gh workflow enable doc-gate.yml
```

---

## 12. 附录

### 12.1 模板索引（速查）

| 模板 | 路径 |
|------|------|
| RFC | `team/templates/RFC-template.md` |
| Epic Issue | `team/templates/issue-epic.md` |
| Feature Issue | `team/templates/issue-feature.md` |
| Task Issue | `team/templates/issue-task.md` |
| PR | `team/templates/pr-template.md` |

### 12.2 脚本索引（速查）

| 脚本 | 路径 | 何时用 |
|------|------|--------|
| init-kanban.sh | `team/scripts/init-kanban.sh` | 新项目立项 |
| create-issue.sh | `team/scripts/create-issue.sh` | 创建 Issue |
| check-docs-sync.sh | `team/scripts/check-docs-sync.sh` | CI 门禁 |
| draft-changelog.sh | `team/scripts/draft-changelog.sh` | CHANGELOG 起草 |
| dashboard-export.sh | `team/scripts/dashboard-export.sh` | 周报 |
| doc-gate.yml | `team/scripts/doc-gate.yml` | 复制到 `.github/workflows/` |

### 12.3 关联协议（速查）

| 协议 | 路径 |
|------|------|
| 通信协议 | `team/protocols/comm.md` |
| 互评协议 | `team/protocols/CROSS-EVAL.md` |
| 工作流 skill | `~/.hermes/profiles/coo/skills/software-development/professional-ai-coding-workflow/SKILL.md` |

### 12.4 决策记录（速查）

| RFC | 主题 | 状态 |
|-----|------|------|
| RFC-001 | 团队协作机制（Team Workflow） | ✅ 已接受（2026-06-13） |

### 12.5 变更日志

| 日期 | 变更 | 作者 |
|------|------|------|
| 2026-06-13 | 初稿 v1.0.0 | COO（agent-coo） |

---

## ✅ 协议生效确认

**本协议自 2026-06-13 起对所有 PROJECT-* 项目生效。**

- [x] CEO 已签字（通过对话确认）
- [x] CTO 已确认（技术方案 review 通过）
- [x] COO 已确认（运营方案 review 通过）

**配套行动**：
1. 各项目 owner 收到本协议后 7 天内完成模板导入
2. 第 2 周硬门禁启用（PROJECT-011 样板先行）
3. 第 3 周所有项目全面启用

---

*文档结束。如有疑问，参考 §10 FAQ 或发起新 RFC。*
---

## 10. 第十章：命令行自动化工单

### 10.1 agent-feature.py 脚本（极强自动化）

**核心脚本**：team/scripts/agent-feature.py

**用法**（在项目根目录运行）：

```bash
# 基础命令
python ../../team/scripts/agent-feature.py "导出 CSV" --description "导出支持日志为 CSV 格式"

# 指定工作目录
python ../../team/scripts/agent-feature.py "导出 CSV" --description "导出支持日志为 CSV 格式" --workdir /c/Users/邱领/Projects/prompt-engine

# 模拟运行（不创建真实 Issue/PR）
python ../../team/scripts/agent-feature.py "导出 CSV" --description "导出支持日志为 CSV 格式" --simulate --workdir /c/Users/邱领/Projects/prompt-engine
```

**自动化工单流程（零交互）**：
1. 自动创建 Issue（标题、body、label 全自动）
2. 自动切分支（feat/<your-key>/v1）
3. 自动生成示例代码 + 测试文件（TDD）
4. 自动 Commit（Conventional Commits）
5. 自动生成 PR body（含自动勾选的 markdown checkbox）
6. 自动调用 gh pr create（无需手动创建 PR）
7. 自动检查文档同步（调用 check-docs-sync.sh）
8. 文档未更新 → 在 GitHub 网页上手动补 CHANGELOG + 点击 "Re-run workflow"

**示例输出**（模拟运行 --simulate）：
```
======================================================================
🤖 Agent Feature Workflow — 极强自动化工单脚本
======================================================================
功能关键帧: export-supported-log-csv
功能描述: 导出支持日志为 CSV 格式
工作目录: C:\Users\邱领\Projects\prompt-engine

📝 自动创建 Issue（模拟）: #9998
🌿 自动创建分支: export-supported-log-csv/v1

🔍 进入目录: C:\Users\邱领\Projects\prompt-engine
💻 自动写代码: export-supported-log-csv
  ✅ 示例代码已生成: examples/export_supported_log_csv.py
  ✅ 测试文件已生成: tests/test_export_supported_log_csv.py

💾 自动提交: feat(export-supported-log-csv): 实现导出 CSV 功能
  ✅ Commit 已提交

📄 检查文档同步...
  ⚠️  未检测到文档变更
  建议：请手动更新 src/support_log_export/ 目录下的文档

🔗 自动创建 PR（模拟）: https://github.com/Colinchiu007/prompt-engine/pull/9999
分支:   export-supported-log-csv/v1

💡 请在 GitHub 网页上手动更新 README.md/CHANGELOG.md，然后点击 'Re-run workflow' 重新触发 CI
```

**注意**：
- 真实场景中，"写代码" 这一步需要你实际的 coding skill（不是示例代码）
- 当前示例代码只是展示文件结构，你可以替换成你的真实实现

---

## 11. 第十一章：Bug 修复极简入口

### 11.1 auto-bug-fix.py 脚本

**核心脚本**：`team/scripts/auto-bug-fix.py`

**用法**（在项目根目录运行）：

```bash
# 最简单的调用（只用标题）
python ../team/scripts/auto-bug-fix.py "console.log 残留"

# 指定 description（可选）
python ../team/scripts/auto-bug-fix.py "console.log 残留" \
  --description "修复 login.js 中残留的 console.log"

# 指定 scope（可选，不传会自动从标题提取）
python ../team/scripts/auto-bug-fix.py "console.log 残留" \
  --scope auth

# 模拟运行（不实际创建 Issue/PR）
python ../team/scripts/auto-bug-fix.py "console.log 残留" --simulate
```

**工作原理**：
- `auto-bug-fix.py` 是 `agent-feature.py` 的**轻量包装**
- 自动生成 `feature_key`：标题 → kebab-case，加 `fix-` 前缀
- 自动生成 `scope`：从英文标题提取
- 自动从 cwd 推断工作目录
- 复用 `agent-feature.py` 的完整流程（Issue / Branch / Code / Commit / PR / CI 门禁）

**和 `agent-feature.py` 的关系**：

| 维度 | agent-feature.py | auto-bug-fix.py |
|------|------------------|-----------------|
| **适用场景** | 新功能 | Bug 修复 |
| **feature_key 前缀** | 自由命名 | 自动加 `fix-` |
| **分支命名** | `feat/<key>/v1` | `feat/fix-<key>/v1`（会被脚本自动调整） |
| **Commit message** | `feat(scope): ...` | `fix(scope): ...`（取决于 scope 来源） |
| **Issue 标签** | `feature` | `feature`（待未来扩展为 `bug`） |
| **完整流程** | ✅ | ✅（完全相同） |
| **复杂度** | 中（多参数） | 极简（一句话） |

**示例运行输出**（模拟模式 `--simulate`）：
```
======================================================================
🐛 Auto Bug Fix — Bug 修复极简入口
======================================================================
原始标题:  console.log 残留
feature_key: fix-console-log-残留
scope:       consolelog
description: console.log 残留 / 自动记录于 C:\Users\邱领\Projects\team\scripts\auto-bug-fix.py

🚀 调用 agent-feature.py ...
  $ python agent-feature.py fix-console-log-残留 --description console.log 残留 --scope consolelog

[agent-feature.py 内部输出]
======================================================================
🤖 Agent Feature Workflow — 极强自动化工单脚本
======================================================================
功能关键帧: fix-console-log-残留
功能描述: console.log 残留 自动记录于 ...
工作目录: C:\Users\邱领\Projects\prompt-engine
  $ git branch --show-current
... (完整流程运行)
```

### 11.2 选择建议

| 场景 | 推荐脚本 |
|------|----------|
| 加新功能 | `agent-feature.py` |
| 修 Bug | `auto-bug-fix.py` |
| 重构（不增功能） | `agent-feature.py` + 手动 scope |
| 配置/工具变更 | `agent-feature.py` + scope=chore |
| 文档更新 | `agent-feature.py` + scope=docs |


---

## 12. 第十二章：Level 2 — Agent 自动诊断（不需 LLM API）

### 12.1 核心原理

在 Hermes Desktop 内运行 `auto-bug-fix.py --auto-diagnose`：

1. **不调用外部 LLM**（如 OpenAI/Claude）
2. **agent（当前会话的我）就是 LLM**——脚本写入诊断请求文件，agent 读文件后给诊断
3. **零额外成本** + **零网络依赖**

### 12.2 工作流

```
你说"修个 bug: console.log 残留"
      ↓
运行 auto-bug-fix.py --auto-diagnose
      ↓
脚本自动：
  1. 写入 .bug-diagnosis-needed.json（包含 bug 描述、scope、feature_key）
  2. 输出"等待 agent 诊断"提示
  3. 轮询 .bug-diagnosis-result.json
      ↓
你在当前会话里说"请读 .bug-diagnosis-needed.json 诊断"
      ↓
agent（我）做：
  1. 读请求文件
  2. 读项目代码（git log、src/、tests/）
  3. 推断根因 + 给出修复建议 + 测试方案
  4. 写入 .bug-diagnosis-result.json
      ↓
脚本继续：
  5. 读到诊断结果
  6. 把诊断信息附加到 PR body
  7. 调 agent-feature.py 走完整流程
  8. 自动清理诊断文件
```

### 12.3 诊断结果文件格式

**请求文件** `.bug-diagnosis-needed.json`：
```json
{
  "bug_title": "console.log 残留",
  "feature_key": "fix-console-log-residue",
  "scope": "core",
  "description": ["..."],
  "project_dir": "C:\Users\邱领\Projects\prompt-engine",
  "git_branch_to_create": "fix-console-log-residue/v1",
  "diagnosis_requested_at": "2026-06-13 19:30:00",
  "status": "pending"
}
```

**结果文件** `.bug-diagnosis-result.json`（agent 写入）：
```json
{
  "status": "completed",
  "root_cause": "login.js:42 直接读取 localStorage.token，但未做 null 检查...",
  "fix_suggestion": "在 login.js:42 加 null 检查...",
  "test_suggestion": "在 tests/test_login.js 加测试...",
  "confidence": 0.85,
  "diagnosed_at": "2026-06-13 19:32:00",
  "files_inspected": ["src/auth/login.js", "src/auth/session.js"]
}
```

### 12.4 完整使用流程

```bash
# 步骤 1：启动 Level 2 模式（带诊断）
cd /c/Users/邱领/Projects/prompt-engine
python ../team/scripts/auto-bug-fix.py "console.log 残留" --auto-diagnose

# 输出：
#   ✅ 诊断请求已写入: .bug-diagnosis-needed.json
#   🛑 等待 agent 诊断
#   ⏳ 等待 agent 完成诊断（最多 300 秒）...

# 步骤 2：在 Hermes 会话里说
#   "请读 .bug-diagnosis-needed.json 诊断 bug"

# agent（我）会：
#   - 读请求文件
#   - 分析项目
#   - 写入诊断结果到 .bug-diagnosis-result.json

# 步骤 3：脚本自动检测到结果，继续走完整流程
#   📋 诊断结果：
#     根因: ...
#     修复: ...
#     置信度: 85.0%
#
#   🚀 调用 agent-feature.py 走完整流程
```

### 12.5 何时用 Level 2 vs 传统模式

| 场景 | 模式 | 命令 |
|------|------|------|
| **明确知道 bug 在哪**（如 console.log 残留） | 传统 | `python auto-bug-fix.py "console.log 残留"` |
| **不确定根因**（如"用户反馈登录慢"） | Level 2 | `python auto-bug-fix.py "登录慢" --auto-diagnose` |
| **CI 失败**，但报错信息不清晰 | Level 2 | `python auto-bug-fix.py "CI 失败" --auto-diagnose` |
| **紧急 hotfix** | 传统 | `python auto-bug-fix.py "紧急" --scope hotfix` |

### 12.6 后续可扩展（Level 3 / 4）

| 级别 | 描述 | 当前状态 |
|------|------|---------|
| **Level 1** | 传统模式（一句命令触发完整流程） | ✅ 完成 |
| **Level 2** | agent 自动诊断（不需 LLM API） | ✅ 完成 |
| **Level 3** | agent 自动写修复代码（不需 LLM API） | 🔜 后续 |
| **Level 4** | CI 失败自动分析 + 自动 PR | 🔜 后续 |


---

## 13. 第十三章：Level 3 — Agent 自动写修复代码（不需 LLM API）

### 13.1 Level 3 vs Level 2

| 维度 | Level 2（diagnose） | Level 3（fix） |
|------|---------------------|-----------------|
| **agent 做什么** | 只诊断 | 诊断 + 实际写代码 |
| **result 文件** | 含 root_cause/fix_suggestion | **多含 files_changed + tests_added** |
| **脚本行为** | 显示诊断（不修改文件） | **自动应用修复**到文件 |
| **你做的事** | 写代码 | review 代码 + approve |
| **风险** | 低（不改文件） | 中（可能改坏） |

### 13.2 工作流

```
你说"修个 bug: 登录慢" --auto-fix
      ↓
auto-bug-fix.py 调 agent-feature.py
      ↓
【Level 3 暂停点】脚本写入 .bug-diagnosis-needed.json
  包含：bug 描述 + 项目路径 + 分支名 + require_files_changed=true
      ↓
你在当前会话说"请诊断 + 写修复代码"
      ↓
agent（我）做：
  1. 读 .bug-diagnosis-needed.json
  2. 读项目代码（git log / git status / 涉及文件）
  3. 推断根因
  4. **实际修改文件**（写入 src/.../xxx.js）
  5. **写测试代码**（写入 tests/...）
  6. 写 .bug-diagnosis-result.json（含 files_changed + tests_added）
      ↓
auto-bug-fix.py 继续：
  7. 读 .bug-diagnosis-result.json
  8. 应用 files_changed 到磁盘（create/modify/delete）
  9. 调 agent-feature.py 走完整流程（commit + PR + CI 门禁）
  10. 清理临时文件
      ↓
你 review PR → approve/拒绝
```

### 13.3 result 文件格式（Level 3 扩展）

```json
{
  "status": "completed",
  "root_cause": "login.js:42 缺少 null 检查",
  "fix_suggestion": "加 if (!token) 守卫",
  "test_suggestion": "加 missing token 测试",
  "confidence": 0.85,
  "files_changed": [
    {
      "path": "src/auth/login.js",
      "action": "modify",  // modify / create / delete
      "content": "完整文件内容..."
    },
    {
      "path": "tests/test_login.js",
      "action": "create",
      "content": "完整测试文件..."
    }
  ],
  "tests_added": ["tests/test_login.js"],
  "files_inspected": ["src/auth/login.js", "package.json"]
}
```

### 13.4 使用

```bash
# Level 3 模式
python ../team/scripts/auto-bug-fix.py "登录慢" --auto-fix

# 输出：
#   🔍 Level 3 (agent 诊断 + 写修复代码)：准备 agent 诊断上下文...
#   ✅ 诊断请求已写入: .bug-diagnosis-needed.json
#   🛑 等待 agent 诊断 + 修复
#   ⏳ 等待 agent 完成诊断（最多 300 秒）...
#
#   提示：在你的 Hermes 会话说
#     '请读 .bug-diagnosis-needed.json 诊断 + 修复bug'

# agent 完成诊断 + 修复后：
#   📋 诊断结果：...
#   🛠️  Level 3: 应用 agent 修复（2 个文件）...
#     ✅ modify: src/auth/login.js
#     ✅ create: tests/test_login.js
#     ✅ 修复应用成功
#
#   🚀 调用 agent-feature.py 走完整流程
```

### 13.5 何时用 Level 1/2/3

| 场景 | 模式 | 命令 |
|------|------|------|
| **明确知道 bug** | Level 1（传统） | `python auto-bug-fix.py "console.log 残留"` |
| **不确定根因** | Level 2 | `python auto-bug-fix.py "登录慢" --auto-diagnose` |
| **明确根因，想自动修** | **Level 3** | **`python auto-bug-fix.py "登录慢" --auto-fix`** |
| **CI 失败** | Level 2 | `python auto-bug-fix.py "CI 失败" --auto-diagnose` |
| **紧急 hotfix** | Level 1 | `python auto-bug-fix.py "紧急" --scope hotfix` |

### 13.6 完整级别路线

| 级别 | 描述 | 状态 |
|------|------|------|
| **Level 1** | 传统模式（一句话 + 完整流程） | ✅ 完成 |
| **Level 2** | agent 自动诊断 | ✅ 完成 |
| **Level 3** | agent 自动写修复代码 | ✅ 完成 |
| **Level 4** | CI 失败自动分析 + 自动 PR | 🔜 后续 |

---

## 14. 第十四章：Level 4 — CI 失败自动修复 + 防循环

### 14.1 核心架构

```
任何 CI 失败（check-docs-sync / Lint / Test）
      ↓
GitHub Action（ci-failure-handler.yml）
  1. 解析失败原因
  2. 检查是否已有 Issue（防重复）
  3. 创建 Bug Issue（含失败详情 + 修复指南）
  4. 在 PR 留评论（@ 用户去本地修复）
      ↓
你在本地收到通知
      ↓
本地方能运行：
  bash ../team/scripts/trigger-agent-fix.sh
      ↓
trigger-agent-fix.sh 自动：
  1. 检查失败次数（防无限循环）
  2. 调 auto-bug-fix.py --auto-fix（Level 3 修复）
  3. 自动 commit + push
  4. CI 自动重跑（验证修复）
      ↓
失败次数 ≥ 3 次
      ↓
自动停止 → 创建"需要 CTO 介入"Issue → 转人工
```

### 14.2 文件清单

| 文件 | 作用 |
|------|------|
| `ci-failure-handler.yml` | GitHub Actions 工作流（监听 CI 失败） |
| `trigger-agent-fix.sh` | 本地包装脚本（含失败次数检查） |
| `auto-fix-loop-counter.sh` | 失败次数追踪工具（count/reset/bump/check/remaining） |
| `.agent-fix-counter` | 运行时文件（记录当前失败次数，每项目一个） |

### 14.3 配置

```yaml
# .github/workflows/ci-failure-handler.yml（已预配置）
# 监听以下 workflow 的失败
workflows: ["check-docs-sync", "CI", "Lint", "Test"]

# 触发条件：只有 failure 才触发
if: ${{ github.event.workflow_run.conclusion == 'failure' }}
```

### 14.4 使用

**安装（一次配置）**：

1. 复制 `ci-failure-handler.yml` 到项目 `.github/workflows/`：
```bash
cp team/scripts/ci-failure-handler.yml PROJECT-011/.github/workflows/
```

2. 在 GitHub 创建 `level-4` label：
```bash
gh label create "level-4" --color "5319e7" --description "Level 4 CI 失败自动检测"
```

**日常使用**：

CI 失败后，自动创建 Bug Issue。你在本地做：

```bash
# 1. 切到失败分支
git fetch origin
git checkout <失败分支名>

# 2. 运行自动修复
cd <项目根目录>
bash ../team/scripts/trigger-agent-fix.sh

# trigger-agent-fix.sh 自动：
#   - 检查失败次数
#   - 调 auto-bug-fix.py --auto-fix
#   - 自动 commit + push
#   - CI 重跑
```

### 14.5 防无限循环机制

| 失败次数 | 动作 |
|----------|------|
| 1-3 | 自动修复 + commit + push |
| ≥ 3 | 停止修复 → 创建"需要 CTO 介入"Issue |
| 4+ | 永久停止该分支的自动修复 |

**重置计数器**：
```bash
bash ../team/scripts/auto-fix-loop-counter.sh reset
```

### 14.6 完整级别路线

| 级别 | 描述 | 状态 |
|------|------|------|
| **Level 1** | 传统模式（一句话 + 完整流程） | ✅ 完成 |
| **Level 2** | agent 自动诊断 | ✅ 完成 |
| **Level 3** | agent 自动写修复代码 | ✅ 完成 |
| **Level 4** | CI 失败自动创建 Issue + 防循环自动修复 | ✅ 完成 |

### 14.7 4 个 Level 使用选择

| 场景 | 命令 |
|------|------|
| 明确知道 bug | `python auto-bug-fix.py "console.log 残留"` |
| 不确定根因 | `python auto-bug-fix.py "登录慢" --auto-diagnose` |
| 想自动修 | `python auto-bug-fix.py "登录慢" --auto-fix` |
| CI 失败 | ✅ 自动触发（CI 创建 Issue → 本地 `trigger-agent-fix.sh`） |
| 紧急 hotfix | `python auto-bug-fix.py "紧急" --scope hotfix` |
