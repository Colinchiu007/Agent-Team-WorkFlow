#!/usr/bin/env bash
#
# dashboard-export.sh — 导出看板状态到 Markdown（监督层用）
#
# 用法：
#   ./dashboard-export.sh --project=<url> --output=<path>
#
# 示例：
#   ./dashboard-export.sh --project=https://github.com/users/Colinchiu007/projects/1 --output=team/reports/dashboard-2026-06-13.md
#
# 功能：
#   1. 查询 GitHub Project v2 的所有 Issue
#   2. 按 Status 分组
#   3. 统计 In Progress / Stale Issues
#   4. 生成 Markdown 报告

set -euo pipefail

# ===== 参数解析 =====
PROJECT_URL=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project=*) PROJECT_URL="${1#--project=}" ;;
    --output=*) OUTPUT="${1#--output=}" ;;
    *) echo "⚠️ 忽略未知参数: $1" ;;
  esac
  shift
done

if [ -z "$PROJECT_URL" ] || [ -z "$OUTPUT" ]; then
  echo "❌ 用法: $0 --project=<url> --output=<path>"
  exit 1
fi

# ===== 前置检查 =====
if ! command -v gh >/dev/null 2>&1; then
  echo "❌ gh CLI 未安装"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "❌ gh CLI 未登录"
  exit 1
fi

# ===== 查询 Issues =====
echo "🔍 查询 Project Issues: $PROJECT_URL"

# 通过 gh CLI 查询项目（v2 需要 GraphQL，这里用 project list + item-list）
PROJECT_NUMBER=$(echo "$PROJECT_URL" | grep -oE '/projects/[0-9]+' | grep -oE '[0-9]+')

if [ -z "$PROJECT_NUMBER" ]; then
  echo "❌ 无法解析 Project 编号"
  exit 1
fi

# gh CLI 2.21+ 支持 project item-list
ISSUES_JSON=$(gh project item-list "$PROJECT_NUMBER" --owner @me --format json --limit 100 2>/dev/null || echo '{"items":[]}')

# 解析并分组（这里用 jq 处理）
TOTAL=$(echo "$ISSUES_JSON" | jq '.items | length' 2>/dev/null || echo 0)
IN_PROGRESS=$(echo "$ISSUES_JSON" | jq '[.items[] | select(.status == "In Progress")] | length' 2>/dev/null || echo 0)
DONE=$(echo "$ISSUES_JSON" | jq '[.items[] | select(.status == "Done")] | length' 2>/dev/null || echo 0)
BLOCKED=$(echo "$ISSUES_JSON" | jq '[.items[] | select(.status == "RFC 评审")] | length' 2>/dev/null || echo 0)

# ===== 生成报告 =====
mkdir -p "$(dirname "$OUTPUT")"

{
  echo "# 📊 项目看板状态"
  echo ""
  echo "> **Project**: $PROJECT_URL"
  echo "> **生成时间**: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""
  echo "---"
  echo ""
  echo "## 📈 概览"
  echo ""
  echo "| 指标 | 数量 |"
  echo "|------|------|"
  echo "| 总 Issue | $TOTAL |"
  echo "| 🚧 进行中 | $IN_PROGRESS |"
  echo "| ✅ Done | $DONE |"
  echo "| ⏸️  阻塞中 | $BLOCKED |"
  echo ""
  echo "## 🚧 进行中"
  echo ""
  if [ "$IN_PROGRESS" -gt 0 ]; then
    echo "$ISSUES_JSON" | jq -r '.items[] | select(.status == "In Progress") | "- [#\(.number)] \(.title) (@\(.assignees[0].login // "unassigned"))"' 2>/dev/null
  else
    echo "_（无）_"
  fi
  echo ""
  echo "## ⏸️  阻塞（RFC 评审）"
  echo ""
  if [ "$BLOCKED" -gt 0 ]; then
    echo "$ISSUES_JSON" | jq -r '.items[] | select(.status == "RFC 评审") | "- [#\(.number)] \(.title)"' 2>/dev/null
  else
    echo "_（无）_"
  fi
  echo ""
  echo "## ✅ Done（最近 10）"
  echo ""
  if [ "$DONE" -gt 0 ]; then
    echo "$ISSUES_JSON" | jq -r '.items[] | select(.status == "Done") | "- [#\(.number)] \(.title)"' 2>/dev/null | head -10
  else
    echo "_（无）_"
  fi
  echo ""
  echo "---"
  echo ""
  echo "_自动生成 by \`team/scripts/dashboard-export.sh\`_"
} > "$OUTPUT"

echo "✅ Dashboard 已导出: $OUTPUT"
echo ""
echo "📌 接下来："
echo "   - 在周报中引用此文件"
echo "   - 检查 🚧 进行中 是否需要支持"
echo "   - 检查 ⏸️  阻塞 是否需要升级"