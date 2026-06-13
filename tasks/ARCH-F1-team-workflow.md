# ARCH-F1 — Team Workflow 机制架构方案

> 对应：PROJECT-009 / PM-PRD-v0.1
> 状态：架构草案，待 CEO 签字

## 1. 架构总览

```
                    ┌─────────────────────────┐
                    │   CEO / COO（决策层）    │
                    └────────────┬────────────┘
                                 │ 决策/RFC 签字
                                 ▼
                    ┌─────────────────────────┐
                    │   PM/CTO/QA（评审层）    │
                    │   - RFC 评审            │
                    │   - PR 评审             │
                    │   - 文档同步门禁        │
                    └────────────┬────────────┘
                                 │ 签字通过
                                 ▼
   ┌─────────────────────────────────────────────────────┐
   │   L3 执行层（开发）                                   │
   │   ┌──────────┐   ┌──────────┐   ┌──────────┐       │
   │   │  Epic    │──▶│ Feature  │──▶│   Task   │       │
   │   │ (Issue)  │   │ (Issue)  │   │ (Issue)  │       │
   │   └──────────┘   └──────────┘   └──────────┘       │
   │         │               │               │           │
   │         └───────────────┴───────────────┘           │
   │                         │ PR                         │
   └─────────────────────────┼───────────────────────────┘
                             ▼
   ┌─────────────────────────────────────────────────────┐
   │   L4 监督层（全自动）                                 │
   │   - GitHub Actions（CI 门禁）                        │
   │   - 看板自动同步（gh CLI）                            │
   │   - 异常升级（CONSOLE + PR 评论）                     │
   └─────────────────────────────────────────────────────┘
```

## 2. 仓库结构

```
Projects/                              ← 工作区根目录
├── team/                              ← 跨项目协作基础设施
│   ├── PROTOCOL.md                    ← D1 团队协议（核心文档）
│   ├── PROJECT-INDEX.md               ← 已有：项目索引
│   ├── PROJECT-REGISTRY.md            ← 已有：项目注册表
│   ├── templates/                     ← D2/D3/D4 模板
│   │   ├── RFC-template.md
│   │   ├── issue-epic.md
│   │   ├── issue-feature.md
│   │   └── issue-task.md
│   ├── RFC/                           ← 决策记录
│   │   ├── RFC-001-team-workflow.md
│   │   └── ...
│   ├── decisions.log                  ← 重大决策时间线
│   ├── checklists/                    ← 评审检查清单
│   │   ├── pr-review.md
│   │   └── release-gate.md
│   └── scripts/                       ← D5-D10 脚本
│       ├── init-kanban.sh
│       ├── create-issue.sh
│       ├── check-docs-sync.sh
│       ├── draft-changelog.sh
│       └── dashboard-export.sh
├── PROJECT-XXX/                       ← 各项目目录
│   ├── .github/workflows/
│   │   └── doc-gate.yml               ← D9 CI 工作流
│   ├── .github/ISSUE_TEMPLATE/
│   │   ├── epic.md                    ← 引用 team/templates
│   │   ├── feature.md
│   │   └── task.md
│   ├── docs/
│   └── ... (项目自身)
```

## 3. 核心数据流

### 3.1 Issue 流转（Epic → Task → Done）

```
1. PM 创建 Epic Issue
   gh issue create --template epic.md --label "epic"
   ↓
2. Epic 下创建 Feature Issues（关联 Epic）
   gh issue create --template feature.md --label "feature" \
     --project "PROJECT-XXX v1.0"
   ↓
3. Feature Ready → 切到 In Progress（看板拖动）
   gh issue edit <N> --add-label "in-progress" --remove-label "ready"
   ↓
4. Feature 下创建 Task Issues（关联 Feature）
   gh issue create --template task.md --label "task" \
     --project "PROJECT-XXX v1.0"
   ↓
5. Task 完成 → 创建 PR → 自动关联
   gh pr create --fill
   ↓
6. PR merge → 自动关闭 Task → 看板自动更新
```

### 3.2 文档门禁（CI 自动）

```yaml
# .github/workflows/doc-gate.yml
on: [pull_request]

jobs:
  doc-sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # 关键：需要看完整 diff

      - name: Check docs sync
        run: |
          bash team/scripts/check-docs-sync.sh \
            --base=${{ github.event.pull_request.base.ref }} \
            --head=${{ github.event.pull_request.head.ref }}
        # 失败 → 红灯，PR 不可合并

      - name: Draft CHANGELOG
        if: always()
        run: |
          bash team/scripts/draft-changelog.sh \
            --output=team/inbox/changelog-draft-${{ github.event.pull_request.number }}.md
```

### 3.3 异常升级（自动 + 看板）

```
Task 卡在 In Progress > 7 天
   ↓ (GitHub Actions cron)
标记为 stale + 评论提醒 owner
   ↓
再 3 天未响应 → 升级 label "needs-cto-attention"
   ↓
CTO 收到 GitHub 通知 → 决策（继续/重新分配/取消）
```

## 4. 关键脚本设计

### 4.1 `init-kanban.sh`（D5）

```bash
#!/usr/bin/env bash
# 初始化项目看板（GitHub Projects v2）
# 用法: init-kanban.sh <project-number> <project-name>

set -euo pipefail
PROJECT_NUM=$1
PROJECT_NAME=$2

# 1. 创建项目（如果不存在）
gh project create --owner @me --title "$PROJECT_NAME" || true

# 2. 创建列（Status 字段选项）
for status in "Backlog" "RFC 评审" "Ready" "In Progress" "Review" "Done" "Released"; do
  gh project field-create $PROJECT_NUM --owner @me --name "Status" \
    --option "$status" || true
done

# 3. 创建视图（Epic/Feature/Task 分组）
gh project view $PROJECT_NUM --owner @me
```

### 4.2 `check-docs-sync.sh`（D7）

```bash
#!/usr/bin/env bash
# 检查 PR 是否同步了文档
# 用法: check-docs-sync.sh <base-ref> <head-ref>

set -e
BASE=$1
HEAD=$2

# 1. 读取 PR body 的 checkbox
DOCS_SYNCED=$(gh pr view --json body -q '.body' | grep -c '^- \[x\] 文档已同步')

if [ "$DOCS_SYNCED" -eq 0 ]; then
  echo "❌ 文档同步 checkbox 未勾选"
  exit 1
fi

# 2. 检查实际 diff
CHANGED_DOCS=$(git diff --name-only "$BASE"..."$HEAD" | grep -E '^(docs/|.*\.md$)' || true)
CHANGED_CODE=$(git diff --name-only "$BASE"..."$HEAD" | grep -vE '^(docs/|.*\.md$|\.github/)' || true)

if [ -n "$CHANGED_CODE" ] && [ -z "$CHANGED_DOCS" ]; then
  echo "❌ 代码有变更但无任何文档更新"
  echo "受影响文件："
  echo "$CHANGED_CODE"
  exit 1
fi

echo "✅ 文档同步检查通过"
```

### 4.3 `draft-changelog.sh`（D8）

```bash
#!/usr/bin/env bash
# 自动起草 CHANGELOG 条目
# 用法: draft-changelog.sh --output <path>

set -e
OUTPUT=${1:-team/inbox/changelog-draft.md}

# 1. 收集 Conventional Commits
COMMITS=$(git log --pretty=format:"%s" $(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)..HEAD 2>/dev/null || true)

# 2. 按 type 分组
echo "# 自动起草 CHANGELOG" > $OUTPUT
echo "" >> $OUTPUT
echo "## Features" >> $OUTPUT
echo "$COMMITS" | grep "^feat" >> $OUTPUT || echo "- (无)" >> $OUTPUT
echo "" >> $OUTPUT
echo "## Bug Fixes" >> $OUTPUT
echo "$COMMITS" | grep "^fix" >> $OUTPUT || echo "- (无)" >> $OUTPUT
# ...

echo "✅ CHANGELOG 草稿: $OUTPUT"
```

## 5. 决策记录（RFC）

每个 Feature 必须有 RFC，格式参考 ADR：

```markdown
# RFC-XXX — <Feature 名称>

## 状态
提议 | 已接受 | 已废弃 | 已替代

## 背景
为什么要做这个？

## 方案对比
### 方案 A
- 优点：
- 缺点：

### 方案 B
- 优点：
- 缺点：

## 决策
选择哪个方案，为什么？

## 后果
- 影响的模块：
- 风险：
- 备选方案（如未来需要可重新评估）：
```

## 6. 与现有体系的对接

| 现有体系 | 对接方式 |
|---------|---------|
| `professional-ai-coding-workflow` skill | D1 PROTOCOL.md 引用并强化 |
| `PROJECT-INDEX.md` | 增加"团队机制"章节 |
| `PROJECT-REGISTRY.md` | 每个项目增加"Workflow"列 |
| 各项目 `docs/PRD.md` | 引用 `team/PROTOCOL.md` |
| 各项目 CHANGELOG | 自动起草 + 人工确认 |

## 7. 启用节奏

| 阶段 | 启用项 | 强制级别 |
|------|--------|---------|
| **第 1 周** | PROTOCOL + 模板 + Issue CLI | 软提示（推荐） |
| **第 2 周** | 文档门禁 PR 模板 checkbox | 软提示 |
| **第 3 周** | GitHub Actions 硬门禁 + CHANGELOG 自动起草 | 硬门禁 |

## 8. 失败模式

| 场景 | 应对 |
|------|------|
| gh CLI 未登录 | 文档明确 `gh auth login` 步骤 |
| GitHub Projects v2 API 限流 | 脚本内置 retry + 指数退避 |
| 项目无 GitHub 仓库 | 文档说明：先 `gh repo create` |
| CHANGELOG 草稿质量差 | 模板约束格式，人工确认 |
| 多项目并发看板同步冲突 | 顺序执行 + 幂等设计 |

---

**作者**：COO（agent-coo）
**日期**：2026-06-13
**版本**：v0.1