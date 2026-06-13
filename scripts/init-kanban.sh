#!/usr/bin/env bash
#
# init-kanban.sh — 初始化项目看板（GitHub Projects v2）
#
# 用法：
#   ./init-kanban.sh <project-name> [--owner=<owner>]
#
# 示例：
#   ./init-kanban.sh "PROJECT-011 prompt-engine v0.8"
#   ./init-kanban.sh "PROJECT-012 语义分句 v1.0" --owner=Colinchiu007
#
# 功能：
#   1. 创建 GitHub Project（如果不存在，幂等）
#   2. 创建 Status 字段（Backlog/RFC 评审/Ready/In Progress/Review/Done/Released）
#   3. 创建 Priority 字段（P0/P1/P2/P3）
#   4. 创建 Type 字段（epic/feature/task）
#   5. 输出 Project URL
#
# 失败处理：
#   - gh CLI 未登录：提示运行 `gh auth login`
#   - Project 已存在：跳过创建（幂等）
#   - 字段已存在：跳过创建（幂等）

set -euo pipefail

# ===== 参数解析 =====
if [ $# -lt 1 ]; then
  echo "❌ 用法: $0 <project-name> [--owner=<owner>]"
  echo "示例: $0 \"PROJECT-011 v0.8\" --owner=Colinchiu007"
  exit 1
fi

PROJECT_NAME="$1"
OWNER="${2:-@me}"
if [[ "$OWNER" == --owner=* ]]; then
  OWNER="${OWNER#--owner=}"
fi

# ===== 前置检查 =====
if ! command -v gh >/dev/null 2>&1; then
  echo "❌ gh CLI 未安装。请运行："
  echo "   winget install GitHub.CLI"
  echo "   或访问 https://cli.github.com/"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "❌ gh CLI 未登录。请运行："
  echo "   gh auth login"
  exit 1
fi

echo "🚀 初始化项目看板：$PROJECT_NAME"
echo "   Owner: $OWNER"
echo ""

# ===== 1. 创建 Project =====
echo "📋 Step 1/4: 创建 GitHub Project..."
PROJECT_URL=$(gh project create --owner "$OWNER" --title "$PROJECT_NAME" --format json 2>/dev/null | jq -r '.url' || echo "")

if [ -z "$PROJECT_URL" ]; then
  # Project 可能已存在，查找
  echo "   ⚠️ Project 可能已存在，尝试查找..."
  PROJECT_URL=$(gh project list --owner "$OWNER" --format json | jq -r --arg name "$PROJECT_NAME" '.projects[] | select(.title == $name) | .url' | head -1)
  if [ -z "$PROJECT_URL" ]; then
    echo "❌ 创建 Project 失败，且未找到同名 Project"
    exit 1
  fi
fi

PROJECT_NUMBER=$(echo "$PROJECT_URL" | grep -oE '/projects/[0-9]+' | grep -oE '[0-9]+')
echo "   ✅ Project URL: $PROJECT_URL"
echo "   ✅ Project Number: $PROJECT_NUMBER"
echo ""

# ===== 2. 创建 Status 字段 =====
echo "📊 Step 2/4: 创建 Status 字段..."
for status in "Backlog" "RFC 评审" "Ready" "In Progress" "Review" "Done" "Released"; do
  gh project field-create "$PROJECT_NUMBER" --owner "$OWNER" \
    --name "Status" --option "$status" >/dev/null 2>&1 || true
  echo "   ✓ Status: $status"
done
echo ""

# ===== 3. 创建 Priority 字段 =====
echo "🎯 Step 3/4: 创建 Priority 字段..."
for priority in "P0" "P1" "P2" "P3"; do
  gh project field-create "$PROJECT_NUMBER" --owner "$OWNER" \
    --name "Priority" --option "$priority" >/dev/null 2>&1 || true
  echo "   ✓ Priority: $priority"
done
echo ""

# ===== 4. 创建 Type 字段 =====
echo "📦 Step 4/4: 创建 Type 字段..."
for type in "epic" "feature" "task" "chore" "bug"; do
  gh project field-create "$PROJECT_NUMBER" --owner "$OWNER" \
    --name "Type" --option "$type" >/dev/null 2>&1 || true
  echo "   ✓ Type: $type"
done
echo ""

# ===== 完成 =====
echo "✅ 看板初始化完成！"
echo ""
echo "📌 接下来："
echo "   1. 创建 Epic Issue:  ./create-issue.sh epic \"<标题>\""
echo "   2. 创建 Feature:     ./create-issue.sh feature \"<标题>\" --epic=<N>"
echo "   3. 创建 Task:        ./create-issue.sh task \"<标题>\" --feature=<N>"
echo ""
echo "🔗 Project URL: $PROJECT_URL"