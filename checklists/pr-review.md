# PR 评审检查清单（CTO 使用）

> 每个 PR 合并前，CTO（或指定 reviewer）必须逐项核对。
> 任何未通过项 → 要求修改后才能合并（除非有 `bypass-doc-gate` label）。

---

## 🚦 强制门禁（自动检查）

| # | 检查项 | 自动/人工 | 失败处理 |
|---|--------|----------|---------|
| 1 | "文档已同步" checkbox 至少勾选 1 项 | 自动（CI） | 红灯，PR 不可合并 |
| 2 | 代码变更 + 无任何文档变更 | 自动（CI） | 红灯 |
| 3 | CHANGELOG 自动起草已生成 | 自动（CI） | 警告（不阻塞） |
| 4 | 单元测试通过 | 自动（CI） | 红灯 |
| 5 | Lint 通过 | 自动（CI） | 红灯 |
| 6 | 无 hardcoded secrets | 自动（CI） | 红灯 |

---

## 🧠 评审维度（人工）

### 1. 代码质量（30 分）

- [ ] 命名规范一致（变量/函数/类）
- [ ] 函数 ≤ 30 行（不含注释）
- [ ] 单一职责（一个函数只做一件事）
- [ ] 无重复代码（DRY 原则）
- [ ] 无死代码 / 未使用导入

### 2. 错误处理（20 分）

- [ ] 所有外部调用有 try/catch
- [ ] 无 `except: pass` 或 `catch {}`
- [ ] 错误信息有上下文（`raise ValueError(f"Invalid email: {email}")`）
- [ ] async 函数有错误处理（try/catch 或 .catch()）

### 3. 测试覆盖（20 分）

- [ ] 新功能有单元测试
- [ ] 边界情况已覆盖（空/null/超大/超小）
- [ ] 错误路径已测试
- [ ] 测试覆盖率不下降

### 4. 安全性（15 分）

- [ ] 无硬编码密钥/Token
- [ ] 无 SQL 注入（参数化查询）
- [ ] 无 XSS（用户输入转义）
- [ ] 无 Shell 注入（不用 `shell=True`）
- [ ] 第三方依赖无已知 CVE（`pip-audit` / `npm audit`）

### 5. 性能与可维护性（15 分）

- [ ] 无明显性能问题（O(n²) 算法、N+1 查询）
- [ ] 关键路径有注释
- [ ] 复杂逻辑有 docstring
- [ ] 不引入技术债（如要引入，需登记 `team/decisions/tech-debt.md`）

---

## 📝 评分标准

| 总分 | 评级 | 处理 |
|------|------|------|
| 90+ | A | 直接合并 |
| 75-89 | B | 建议修改后合并 |
| 60-74 | C | 必须修改后重新评审 |
| <60 | D | 拒绝合并，要求重构 |

---

## 🚪 门禁绕过流程

**当 PR 申请绕过时**：

1. 确认绕过原因合理（P0 hotfix / 实验性 feature）
2. Owner 或 Reviewer 加 `bypass-doc-gate` label：
   ```bash
   gh pr edit <PR号> --add-label "bypass-doc-gate"
   ```
3. 在 PR 评论中明确"事后必须补文档的时间"（如 24h / 7d）
4. 合并后，CTO 创建一个 follow-up Issue 跟踪补文档

---

## ✅ 合并前最终确认

- [ ] 所有 CI 检查通过（或已 bypass）
- [ ] CTO Review 通过
- [ ] 至少 1 个 Approve
- [ ] 关联 Issue 已关联（`Closes #XXX`）
- [ ] 分支已同步最新 main

**合并命令**：
```bash
# 常规合并
gh pr merge <PR号> --squash --delete-branch

# 绕过合并（需先加 label）
gh pr merge <PR号> --squash --delete-branch  # bypass 已加 label
```