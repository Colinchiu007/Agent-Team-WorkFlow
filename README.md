# 🤝 Agent-Team-WorkFlow

> 所有 PROJECT-* 项目统一使用的**团队协作自动化机制**。Level 1-4 全自动，你说一句话我就全搞定。

**GitHub**：https://github.com/Colinchiu007/Agent-Team-WorkFlow

---

## 🚀 一句话触发（3 个 Skill）

| Skill | 你说的话 | 我做的事 |
|-------|---------|---------|
| **feature-workflow** | "做导出CSV功能" | PM-PRD → 架构 → 脚本执行 → Code Review → 文档同步 (完整5阶段) |
| **bug-fix-workflow** | "修个bug: console.log残留" | 自动诊断 → 自动写修复代码 → 自动 PR |
| **ci-doc-fix** | "CI红了" | 自动补文档 → git push → CI 重跑 |

---

## 🎯 自动化级别（Level 1-4）

| 级别 | 自动化内容 | 脚本 |
|------|-----------|------|
| **Level 1** | 一句话触发完整流程（Issue/Branch/Commit/PR/CI） | `agent-feature.py` |
| **Level 2** | agent 自动诊断（不需 LLM API） | `auto-bug-fix.py --auto-diagnose` |
| **Level 3** | agent 自动写修复代码（不需 LLM API） | `auto-bug-fix.py --auto-fix` |
| **Level 4** | CI 失败自动创建 Issue + 防循环修复 | `ci-failure-handler.yml` + `trigger-agent-fix.sh` |

**核心**：所有操作在对话中完成，不需开终端、不需敲命令、不需上 GitHub 改文件。

---

## 📂 仓库结构

```
Agent-Team-WorkFlow/
├── PROTOCOL.md              ← 团队宪法（14章完整版）
├── scripts/                 ← 核心脚本（10个）
│   ├── agent-feature.py         Level 1-3 新功能主入口
│   ├── auto-bug-fix.py          Level 1-3 Bug修复入口
│   ├── ci-failure-handler.yml   Level 4 CI 工作流
│   ├── trigger-agent-fix.sh     Level 4 本地包装脚本
│   ├── auto-fix-loop-counter.sh Level 4 防循环计数器
│   └── doc-gate.yml             CI 文档硬门禁配置
├── templates/                ← Issue/PR/RFC 模板（5个）
├── RFC/ + decisions/         ← 决策记录
├── tasks/                    ← PRD + 架构文档
└── checklists/               ← 评审清单
```

---

## 📑 快速导航

| 内容 | 链接 |
|------|------|
| **协议（必读）** | [PROTOCOL.md](./PROTOCOL.md)（14章，完整版） |
| **决策记录** | [RFC-001](./RFC/RFC-001-team-workflow.md) |
| **脚本源码** | [scripts/](./scripts/)（10个） |
| **模板** | [templates/](./templates/)（Issue/PR/RFC 各类型） |
| **检查清单** | [checklists/](./checklists/)（PR Review） |

---

## 📋 在新项目启用

```bash
# 1. 复制 CI 硬门禁
curl -O https://raw.githubusercontent.com/Colinchiu007/Agent-Team-WorkFlow/main/scripts/doc-gate.yml
mkdir -p .github/workflows
mv doc-gate.yml .github/workflows/

# 2. 复制 CI 失败处理器（Level 4）
curl -O https://raw.githubusercontent.com/Colinchiu007/Agent-Team-WorkFlow/main/scripts/ci-failure-handler.yml
mv ci-failure-handler.yml .github/workflows/

# 3. 创建 GitHub Project
bash scripts/init-kanban.sh "PROJECT-XXX vX.Y"

# 4. 创建 label
gh label create "bypass-doc-gate" --color "d93f0b"
gh label create "level-4" --color "5319e7"
```

---

## 📜 变更记录

| 日期 | 变更 |
|------|------|
| 2026-06-13 | **完整交付**：Level 1-4 全自动 + 3 个 Skill + 集成 professional-ai-coding-workflow |

---

*由 Agent-Team-WorkFlow 维护*