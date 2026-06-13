#!/usr/bin/env bash
#
# create-issue.sh — 创建 GitHub Issue 并关联到项目看板
#
# 用法：
#   ./create-issue.sh epic "<标题>" [--project=<url>] [--milestone=<vX.Y.Z>]
#   ./create-issue.sh feature "<标题>" --epic=<N> [--project=<url>] [--milestone=<vX.Y.Z>]
#   ./create-issue.sh task "<标题>" --feature=<N> [--project=<url>] [--assignee=<user>]
#   ./create-issue.sh chore "<标题>"
#
# 示例：
#   ./create-issue.sh epic "v0.8 发布"
#   ./create-issue.sh feature "新增导出 PDF" --epic=42 --milestone=v0.8
#   ./create-issue.sh task "实现 utils.py" --feature=43 --assignee=me
#
# 功能：
#   1. 根据类型选择对应模板（team/templates/issue-*.md）
#   2. 自动打 label（epic/feature/task）
#   3. 关联到 Project 和 Milestone
#   4. 输出 Issue URL

set -euo pipefail

# ===== 参数解析 =====
if [ $# -lt 2 ]; then
  echo "❌ 用法:"
  echo "   $0 epic \"<标题>\" [--project=<url>] [--milestone=<vX.Y.Z>]"
  echo "   $0 feature \"<标题>\" --epic=<N> [--project=<url>] [--milestone=<vX.Y.Z>]"
  echo "   $0 task \"<标题>\" --feature=<N> [--assignee=<user>]"
  exit 1
fi

ISSUE_TYPE="$1"
shift
TITLE="$1"
shift

# 解析可选参数
EPIC=""
FEATURE=""
PROJECT=""
MILESTONE=""
ASSIGNEE=""

for arg in "$@"; do
  case "$arg" in
    --epic=*) EPIC="${arg#--epic=}" ;;
    --feature=*) FEATURE="${arg#--feature=}" ;;
    --project=*) PROJECT="${arg#--project=}" ;;
    --milestone=*) MILESTONE="${arg#--milestone=}" ;;
    --assignee=*) ASSIGNEE="${arg#--assignee=}" ;;
    *) echo "⚠️ 忽略未知参数: $arg" ;;
  esac
done

# ===== 类型校验 =====
case "$ISSUE_TYPE" in
  epic|feature|task|chore) ;;
  *) echo "❌ 不支持的类型: $ISSUE_TYPE（支持: epic/feature/task/chore）"; exit 1 ;;
esac

# ===== 前置检查 =====
if ! command -v gh >/dev/null 2>&1; then
  echo "❌ gh CLI 未安装"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "❌ gh CLI 未登录，请运行: gh auth login"
  exit 1
fi

# ===== 验证依赖关系 =====
if [ "$ISSUE_TYPE" = "feature" ] && [ -z "$EPIC" ]; then
  echo "❌ 创建 Feature 必须指定 --epic=<N>"
  exit 1
fi

if [ "$ISSUE_TYPE" = "task" ] && [ -z "$FEATURE" ]; then
  echo "❌ 创建 Task 必须指定 --feature=<N>"
  exit 1
fi

# ===== 选择模板 =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/../templates/issue-$ISSUE_TYPE.md"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "⚠️ 模板文件不存在: $TEMPLATE_FILE"
  echo "   使用空 body 创建"
  BODY=""
else
  BODY=$(cat "$TEMPLATE_FILE")
fi

# ===== 添加关联信息 =====
if [ -n "$EPIC" ]; then
  BODY="$BODY

---

**关联 Epic**：#$EPIC
"
fi

if [ -n "$FEATURE" ]; then
  BODY="$BODY

**关联 Feature**：#$FEATURE
"
fi

# ===== 创建 Issue =====
echo "🚀 创建 $ISSUE_TYPE Issue: $TITLE"

CREATE_ARGS=(
  --title "[$ISSUE_TYPE] $TITLE"
  --label "$ISSUE_TYPE"
  --body "$BODY"
)

if [ -n "$MILESTONE" ]; then
  CREATE_ARGS+=(--milestone "$MILESTONE")
fi

if [ -n "$ASSIGNEE" ]; then
  CREATE_ARGS+=(--assignee "$ASSIGNEE")
fi

ISSUE_URL=$(gh issue create "${CREATE_ARGS[@]}" 2>&1 | tail -1)

if [ -z "$ISSUE_URL" ]; then
  echo "❌ Issue 创建失败"
  exit 1
fi

ISSUE_NUMBER=$(echo "$ISSUE_URL" | grep -oE '/issues/[0-9]+' | grep -oE '[0-9]+')

echo "   ✅ Issue 创建成功: #$ISSUE_NUMBER"
echo "   🔗 URL: $ISSUE_URL"

# ===== 关联到 Project =====
if [ -n "$PROJECT" ]; then
  echo ""
  echo "📋 关联到 Project: $PROJECT"
  # GitHub Projects v2 的 issue 添加通过 GraphQL API，gh CLI 暂不支持直接添加
  # 提示用户手动添加或使用 gh project 命令（beta）
  echo "   ⚠️  当前 gh CLI 版本不支持自动添加 Issue 到 Project v2"
  echo "   💡 请手动访问 Project 页面添加，或使用:"
  echo "      gh project item-add <PROJECT_NUM> --owner @me --url $ISSUE_URL"
  echo "   （需要 gh CLI 2.21+）"
fi

echo ""
echo "📌 下一步："
echo "   - 编辑 Issue 添加详细信息"
echo "   - 创建子 Task（如果是 Epic/Feature）"
echo "   - 在看板上拖动到对应状态列"