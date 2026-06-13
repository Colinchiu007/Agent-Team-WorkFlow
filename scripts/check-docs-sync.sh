#!/usr/bin/env bash
#
# check-docs-sync.sh — 检查 PR 是否同步了文档（CI 硬门禁）
#
# 用法（在 GitHub Actions 中）：
#   ./check-docs-sync.sh --base=$GITHUB_BASE_REF --head=$GITHUB_HEAD_REF
#
# 用法（本地）：
#   ./check-docs-sync.sh --base=main --head=feat/my-feature
#
# 退出码：
#   0 — 通过
#   1 — 失败（CI 红灯）
#
# 检查规则：
#   1. PR body 必须勾选"文档已同步" checkbox
#   2. 代码变更必须有对应的文档变更
#   3. 纯代码/配置变更（无业务逻辑）可绕过，但需明确原因

set -euo pipefail

# ===== 参数解析 =====
BASE=""
HEAD=""
PR_BODY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base=*) BASE="${1#--base=}" ;;
    --head=*) HEAD="${1#--head=}" ;;
    --pr-body=*) PR_BODY="${1#--pr-body=}" ;;
    *) echo "⚠️ 忽略未知参数: $1" ;;
  esac
  shift
done

if [ -z "$BASE" ] || [ -z "$HEAD" ]; then
  echo "❌ 用法: $0 --base=<ref> --head=<ref> [--pr-body=<text>]"
  exit 1
fi

echo "🔍 检查文档同步：$BASE → $HEAD"
echo ""

# ===== 1. 获取 PR body =====
if [ -z "$PR_BODY" ]; then
  if command -v gh >/dev/null 2>&1; then
    PR_NUMBER="${PR_NUMBER:-}"
    if [ -n "$PR_NUMBER" ]; then
      PR_BODY=$(gh pr view "$PR_NUMBER" --json body -q '.body' 2>/dev/null || echo "")
    fi
  fi
fi

# ===== 2. 检查 checkbox =====
echo "1️⃣  检查 PR body checkbox..."

CHECKBOX_PASSED=false
if [ -n "$PR_BODY" ]; then
  # 检查至少有一个 "文档已同步" checkbox 被勾选
  if echo "$PR_BODY" | grep -qE '^\s*-\s*\[x\]\s*(docs/PRD\.md|CHANGELOG\.md|README\.md|docs/AGENTS\.md|docs/ARCH-.*\.md)'; then
    CHECKBOX_PASSED=true
  fi
  # 检查是否有明确"无需文档同步"的说明
  if echo "$PR_BODY" | grep -qE '^\s*-\s*\[x\]\s*(仅修改注释|仅修改 lockfile)'; then
    CHECKBOX_PASSED=true
    echo "   ✓ 明确说明无需文档同步（注释/lockfile）"
  fi
fi

if [ "$CHECKBOX_PASSED" = false ]; then
  echo "   ❌ PR body 未勾选任何文档同步 checkbox"
  echo ""
  echo "   必须至少勾选以下其中一项："
  echo "     - [ ] docs/PRD.md"
  echo "     - [ ] CHANGELOG.md"
  echo "     - [ ] README.md"
  echo "     - [ ] docs/AGENTS.md"
  echo "     - [ ] docs/ARCH-<feature>.md"
  echo ""
  echo "   或明确说明无需文档同步："
  echo "     - [ ] 仅修改注释/格式/测试"
  echo "     - [ ] 仅修改 lockfile"
  exit 1
fi
echo "   ✅ Checkbox 通过"
echo ""

# ===== 3. 检查实际 diff =====
echo "2️⃣  检查 git diff 文档变更..."

# 获取变更的文件
CHANGED_FILES=$(git diff --name-only "$BASE"..."$HEAD" 2>/dev/null || echo "")

if [ -z "$CHANGED_FILES" ]; then
  echo "   ⚠️ 无法获取 diff（可能 ref 不存在）"
  exit 1
fi

# 分类
CODE_CHANGES=$(echo "$CHANGED_FILES" | grep -vE '^(\.github/|.*\.md$|.*\.lock$|.*package-lock\.json$|.*yarn\.lock$|.*poetry\.lock$|.*Pipfile\.lock$|.*\.gitignore$)' || true)
DOC_CHANGES=$(echo "$CHANGED_FILES" | grep -E '^(docs/|.*\.md$|\.github/)' || true)
LOCKFILE_CHANGES=$(echo "$CHANGED_FILES" | grep -E '\.(lock|lock\.json)$' || true)

CODE_COUNT=$(echo -n "$CODE_CHANGES" | grep -c '.' || echo 0)
DOC_COUNT=$(echo -n "$DOC_CHANGES" | grep -c '.' || echo 0)
LOCKFILE_COUNT=$(echo -n "$LOCKFILE_CHANGES" | grep -c '.' || echo 0)

echo "   📊 变更统计："
echo "      代码变更: $CODE_COUNT 个文件"
echo "      文档变更: $DOC_COUNT 个文件"
echo "      Lockfile: $LOCKFILE_COUNT 个文件"
echo ""

# ===== 4. 决策 =====
# 场景 A：纯文档变更 → 通过
if [ "$CODE_COUNT" -eq 0 ]; then
  echo "   ✅ 纯文档变更，无需额外检查"
  exit 0
fi

# 场景 B：纯 lockfile 变更 → 通过
if [ "$CODE_COUNT" -eq 0 ] && [ "$LOCKFILE_COUNT" -gt 0 ]; then
  echo "   ✅ 纯 lockfile 变更，无需文档同步"
  exit 0
fi

# 场景 C：有代码变更，必须有文档变更
if [ "$CODE_COUNT" -gt 0 ] && [ "$DOC_COUNT" -eq 0 ]; then
  echo "   ❌ 代码有变更但无任何文档更新"
  echo ""
  echo "   受影响的代码文件："
  echo "$CODE_CHANGES" | head -10 | sed 's/^/     - /'
  if [ "$CODE_COUNT" -gt 10 ]; then
    echo "     ...（共 $CODE_COUNT 个）"
  fi
  echo ""
  echo "   💡 解决方案（二选一）："
  echo "     A. 同步更新对应文档（CHANGELOG.md 必更新）"
  echo "     B. 申请绕过门禁（加 'bypass-doc-gate' label，说明原因）"
  exit 1
fi

echo "   ✅ 代码 + 文档均有变更，通过"
exit 0