#!/usr/bin/env bash
#
# draft-changelog.sh — 自动起草 CHANGELOG 条目
#
# 用法（在 GitHub Actions 中）：
#   ./draft-changelog.sh --output=team/inbox/changelog-draft-${{ github.event.pull_request.number }}.md
#
# 用法（本地）：
#   ./draft-changelog.sh --output=/tmp/changelog-draft.md [--since-tag=v0.7.0]
#
# 功能：
#   1. 收集 Conventional Commits（feat/fix/docs/refactor/perf/test/chore）
#   2. 按 type 分组
#   3. 生成 CHANGELOG 草稿到指定路径
#   4. 人工确认后合并到 CHANGELOG.md

set -euo pipefail

# ===== 参数解析 =====
OUTPUT=""
SINCE_TAG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output=*) OUTPUT="${1#--output=}" ;;
    --since-tag=*) SINCE_TAG="${1#--since-tag=}" ;;
    *) echo "⚠️ 忽略未知参数: $1" ;;
  esac
  shift
done

if [ -z "$OUTPUT" ]; then
  echo "❌ 必须指定 --output=<path>"
  exit 1
fi

# ===== 确定起始 ref =====
if [ -z "$SINCE_TAG" ]; then
  # 自动查找最近的 tag
  SINCE_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
  if [ -z "$SINCE_TAG" ]; then
    # 无 tag，用首次 commit
    SINCE_TAG=$(git rev-list --max-parents=0 HEAD 2>/dev/null | tail -1 || echo "")
  fi
fi

if [ -z "$SINCE_TAG" ]; then
  echo "⚠️ 无法确定起始 ref，使用最近 50 条 commit"
  RANGE="HEAD~50..HEAD"
else
  RANGE="$SINCE_TAG..HEAD"
  echo "📌 范围: $RANGE"
fi

# ===== 收集 commits =====
echo "🔍 收集 Conventional Commits..."

# 获取所有 commit（format: hash|type|subject）
COMMITS=$(git log --pretty=format:"%H|%s" "$RANGE" 2>/dev/null || echo "")

if [ -z "$COMMITS" ]; then
  echo "⚠️ 无新 commit，无需生成 CHANGELOG"
  exit 0
fi

# ===== 按 type 分组 =====
FEATURES=""
BUG_FIXES=""
DOCUMENTATION=""
REFACTORING=""
PERFORMANCE=""
TESTS=""
CHORE=""
OTHER=""

while IFS='|' read -r hash subject; do
  [ -z "$hash" ] && continue

  # 解析 Conventional Commit type
  TYPE=$(echo "$subject" | sed -nE 's/^([a-z]+)(\([^)]+\))?!?:\s.*/\1/p')
  SCOPE=$(echo "$subject" | sed -nE 's/^[a-z]+\(([^)]+)\)!?:\s.*/\1/p')
  DESCRIPTION=$(echo "$subject" | sed -nE 's/^[a-z]+(\([^)]+\))?!?:\s(.*)/\2/p')

  # 短 hash
  SHORT_HASH="${hash:0:7}"

  case "$TYPE" in
    feat)
      if [ -n "$SCOPE" ]; then
        FEATURES+="- **$SCOPE**: $DESCRIPTION ([$SHORT_HASH])"$'\n'
      else
        FEATURES+="- $DESCRIPTION ([$SHORT_HASH])"$'\n'
      fi
      ;;
    fix)
      if [ -n "$SCOPE" ]; then
        BUG_FIXES+="- **$SCOPE**: $DESCRIPTION ([$SHORT_HASH])"$'\n'
      else
        BUG_FIXES+="- $DESCRIPTION ([$SHORT_HASH])"$'\n'
      fi
      ;;
    docs)
      DOCUMENTATION+="- $DESCRIPTION ([$SHORT_HASH])"$'\n'
      ;;
    refactor)
      REFACTORING+="- $DESCRIPTION ([$SHORT_HASH])"$'\n'
      ;;
    perf)
      PERFORMANCE+="- $DESCRIPTION ([$SHORT_HASH])"$'\n'
      ;;
    test)
      TESTS+="- $DESCRIPTION ([$SHORT_HASH])"$'\n'
      ;;
    chore)
      CHORE+="- $DESCRIPTION ([$SHORT_HASH])"$'\n'
      ;;
    *)
      OTHER+="- $subject ([$SHORT_HASH])"$'\n'
      ;;
  esac
done <<< "$COMMITS"

# ===== 生成草稿 =====
mkdir -p "$(dirname "$OUTPUT")"

{
  echo "# 📝 CHANGELOG 自动起草"
  echo ""
  echo "> **范围**: \`$RANGE\`"
  echo "> **生成时间**: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "> **状态**: ⏳ 待人工确认"
  echo ""
  echo "---"
  echo ""

  echo "## Features"
  echo ""
  if [ -n "$FEATURES" ]; then
    echo -n "$FEATURES"
  else
    echo "_（无）_"
  fi
  echo ""

  echo "## Bug Fixes"
  echo ""
  if [ -n "$BUG_FIXES" ]; then
    echo -n "$BUG_FIXES"
  else
    echo "_（无）_"
  fi
  echo ""

  echo "## Performance"
  echo ""
  if [ -n "$PERFORMANCE" ]; then
    echo -n "$PERFORMANCE"
  else
    echo "_（无）_"
  fi
  echo ""

  echo "## Refactoring"
  echo ""
  if [ -n "$REFACTORING" ]; then
    echo -n "$REFACTORING"
  else
    echo "_（无）_"
  fi
  echo ""

  echo "## Documentation"
  echo ""
  if [ -n "$DOCUMENTATION" ]; then
    echo -n "$DOCUMENTATION"
  else
    echo "_（无）_"
  fi
  echo ""

  echo "## Tests"
  echo ""
  if [ -n "$TESTS" ]; then
    echo -n "$TESTS"
  else
    echo "_（无）_"
  fi
  echo ""

  echo "## Chore"
  echo ""
  if [ -n "$CHORE" ]; then
    echo -n "$CHORE"
  else
    echo "_（无）_"
  fi
  echo ""

  echo "## Other"
  echo ""
  if [ -n "$OTHER" ]; then
    echo -n "$OTHER"
  else
    echo "_（无）_"
  fi
  echo ""

  echo "---"
  echo ""
  echo "## ✅ 确认步骤"
  echo ""
  echo "1. 检查以上条目是否准确（特别是 scope 和 description）"
  echo "2. 删除不相关的条目（如 chore 中的版本号 bump）"
  echo "3. 补充用户可见的变更说明（如 breaking changes）"
  echo "4. 合并到 \`CHANGELOG.md\` 的 \`[Unreleased]\` 区块："
  echo ""
  echo '```markdown'
  echo "## [Unreleased]"
  echo ""
  # 提取 Features 和 Bug Fixes 作为建议合并内容
  if [ -n "$FEATURES" ]; then
    echo "### Added"
    echo ""
    echo -n "$FEATURES"
  fi
  if [ -n "$BUG_FIXES" ]; then
    echo "### Fixed"
    echo ""
    echo -n "$BUG_FIXES"
  fi
  if [ -n "$OTHER" ]; then
    echo "### Changed"
    echo ""
    echo -n "$OTHER"
  fi
  echo '```'
} > "$OUTPUT"

echo "✅ CHANGELOG 草稿已生成：$OUTPUT"
echo ""
echo "📌 接下来："
echo "   1. 打开 $OUTPUT"
echo "   2. 人工审阅和调整"
echo "   3. 合并到 CHANGELOG.md 的 [Unreleased] 区块"