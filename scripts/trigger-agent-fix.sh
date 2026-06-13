#!/usr/bin/env bash
# trigger-agent-fix.sh — Level 4: CI 失败后本地自动修复包装脚本
#
# 用法：
#   bash trigger-agent-fix.sh [--workdir <路径>] [--ci-log <错误日志>]
#
# 工作流：
#   1. 记录失败次数（防无限循环）
#   2. 调用 auto-bug-fix.py --auto-fix
#   3. 检查修复结果
#   4. 自动 commit + push 触发 CI 重跑
#
# 适用场景：在本地由 ci-failure-handler.yml 创建的 Issue 触发

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="${PWD}"
CI_LOG=""
SIMULATE=false

# 解析参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --workdir)
      WORKDIR="$2"
      shift 2
      ;;
    --ci-log)
      CI_LOG="$2"
      shift 2
      ;;
    --simulate)
      SIMULATE=true
      shift
      ;;
    *)
      echo "❌ 未知参数: $1"
      echo "用法: bash trigger-agent-fix.sh [--workdir <路径>] [--ci-log <日志>] [--simulate]"
      exit 1
      ;;
  esac
done

echo "=" * 60
echo "🔧 Level 4: 自动修复触发器"
echo "=" * 60
echo "工作目录: $WORKDIR"
echo "CI 日志: ${CI_LOG:-无}"
echo ""

# Step 1: 检查失败次数
COUNTER_FILE="${WORKDIR}/.agent-fix-counter"
MAX_FIX_ATTEMPTS=3

if [ -f "$COUNTER_FILE" ]; then
  FIX_COUNT=$(cat "$COUNTER_FILE")
  FIX_COUNT=$((FIX_COUNT + 1))
else
  FIX_COUNT=1
fi

echo "[1/5] 检查失败次数..."

if [ "$FIX_COUNT" -gt "$MAX_FIX_ATTEMPTS" ]; then
  echo "  ❌ 已失败 $FIX_COUNT 次，超过上限 $MAX_FIX_ATTEMPTS 次"
  echo "  💡 转人工处理 — 创建需要 CTO 介入的 Issue"
  echo "$FIX_COUNT" > "$COUNTER_FILE"

  BODY="## 🔴 自动修复次数超限

- 失败次数: $FIX_COUNT / $MAX_FIX_ATTEMPTS
- 工作目录: $WORKDIR
- CI 日志: ${CI_LOG:-无}
- 时间: $(date)

自动修复已停止。请 CTO 手动介入。
"

  gh issue create \
    --title "需要 CTO 介入: 自动修复失败 $FIX_COUNT 次" \
    --body "$BODY" \
    --label "bug,cto-required"

  exit 1
fi

echo "  ✅ 第 $FIX_COUNT / $MAX_FIX_ATTEMPTS 次修复尝试"
echo "$FIX_COUNT" > "$COUNTER_FILE"

# Step 2: 生成 bug 标题
echo ""
echo "[2/5] 生成 Bug 修复参数..."

BUG_TITLE="CI 修复-第${FIX_COUNT}次"
if [ -n "$CI_LOG" ]; then
  BUG_TITLE="CI 修复: $(echo "$CI_LOG" | head -c 50)"
fi

echo "  Bug 标题: $BUG_TITLE"

# Step 3: 运行 auto-bug-fix.py --auto-fix
echo ""
echo "[3/5] 运行 auto-bug-fix.py --auto-fix..."
echo ""

cd "$WORKDIR"

CMD="python ${SCRIPT_DIR}/auto-bug-fix.py '${BUG_TITLE}' --auto-fix"
if [ "$SIMULATE" = true ]; then
  CMD="$CMD --simulate"
fi

eval "$CMD"

FIX_EXIT_CODE=$?
if [ "$FIX_EXIT_CODE" -ne 0 ]; then
  echo "  ❌ 自动修复失败（退出码 $FIX_EXIT_CODE）"
  exit $FIX_EXIT_CODE
fi

# Step 4: 推送修复（触发 CI 重跑）
echo ""
echo "[4/5] 推送修复代码..."

if [ "$SIMULATE" = false ]; then
  CURRENT_BRANCH=$(git branch --show-current)
  if [ -n "$CURRENT_BRANCH" ]; then
    echo "  推送到分支: $CURRENT_BRANCH"
    git -c http.proxy=http://127.0.0.1:7892 -c https.proxy=http://127.0.0.1:7892 push origin "$CURRENT_BRANCH"
    echo "  ✅ 推送成功，CI 将自动重跑"
  else
    echo "  ⚠️  无法检测当前分支，跳过推送"
  fi
else
  echo "  (模拟模式，跳过推送)"
fi

# Step 5: 完成
echo ""
echo "[5/5] 完成"
echo "=" * 60
echo "✅ Level 4 自动修复完成"
echo "  - 修复尝试: $FIX_COUNT / $MAX_FIX_ATTEMPTS"
echo "  - 分支: $(git branch --show-current)"
echo "  - CI 状态: 等待重跑..."
echo "  - 如继续失败，最多重试 $((MAX_FIX_ATTEMPTS - FIX_COUNT)) 次"
echo "=" * 60