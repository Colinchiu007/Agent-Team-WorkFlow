# 🤝 QClaw Team Workflow

> 团队协作机制、协议、模板、脚本 — 所有 PROJECT-* 项目统一使用。

## 📑 快速导航

- **[PROTOCOL.md](./PROTOCOL.md)** — 团队交付协作协议（必读，26 KB 完整版）
- **[RFC-001](./RFC/RFC-001-team-workflow.md)** — 机制决策记录
- **[templates/](./templates/)** — Issue / PR / RFC 模板
- **[scripts/](./scripts/)** — 工具脚本（5 个 + CI 配置）
- **[checklists/](./checklists/)** — 评审清单
- **[decisions/](./decisions/)** — 决策时间线

## 🚀 在新项目启用

```bash
# 1. 复制 CI 配置
curl -O https://raw.githubusercontent.com/Colinchiu007/qclaw-team-workflow/main/scripts/doc-gate.yml
mkdir -p .github/workflows
mv doc-gate.yml .github/workflows/doc-gate.yml

# 2. 复制脚本（可选，本地验证用）
git clone https://github.com/Colinchiu007/qclaw-team-workflow.git /tmp/team-wf
cp -r /tmp/team-wf/scripts/* ./team/scripts/

# 3. 创建 GitHub Project
bash scripts/init-kanban.sh "PROJECT-XXX vX.Y"

# 4. 在 GitHub 创建 bypass-doc-gate label
gh label create "bypass-doc-gate" --color "d93f0b" --description "绕过文档同步门禁（需事后补文档）"
```

## 🎯 核心机制

- **4 层架构**：L1 决策 → L2 评审 → L3 执行 → L4 监督
- **3 粒度追踪**：Epic / Feature / Task
- **硬门禁**：CI 强制检查文档同步
- **AI 起草**：Conventional Commits 自动转 CHANGELOG

## 📖 详细文档

完整使用指南见 [PROTOCOL.md](./PROTOCOL.md)（含 10 个 FAQ + 错误处理）。

## 📜 变更记录

| 日期 | 变更 |
|------|------|
| 2026-06-13 | 初始 v1.0.0：4 层机制 + 5 脚本 + 5 模板 + 1 协议 + 1 CI 配置 |

---

*由 QClaw 智能团队 COO 角色维护*