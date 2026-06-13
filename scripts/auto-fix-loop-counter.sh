#!/usr/bin/env bash
# auto-fix-loop-counter.sh — Level 4: 自动修复失败次数追踪
#
# 用法：
#   bash auto-fix-loop-counter.sh <action> [<workdir>]
#
# 动作：
#   count   — 返回当前失败次数（数字）
#   reset   — 重置计数器为 0
#   check   — 检查是否超过上限，返回 true/false
#   bump    — 失败次数 +1，返回新次数
#
# 配置：
#   MAX_FIX_ATTEMPTS=3 — 最大修复尝试次数

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION="${1:-count}"
WORKDIR="${2:-${PWD}}"
COUNTER_FILE="${WORKDIR}/.agent-fix-counter"
MAX_FIX_ATTEMPTS=3

# 确保工作目录存在
if [ ! -d "$WORKDIR" ]; then
  echo "❌ 工作目录不存在: $WORKDIR"
  exit 1
fi

# 读取当前计数
get_count() {
  if [ -f "$COUNTER_FILE" ]; then
    cat "$COUNTER_FILE"
  else
    echo "0"
  fi
}

case "$ACTION" in
  count)
    # 返回当前失败次数
    get_count
    ;;

  reset)
    # 重置计数器
    echo "0" > "$COUNTER_FILE"
    echo "✅ 计数器已重置为 0"
    ;;

  check)
    # 检查是否超过上限
    COUNT=$(get_count)
    if [ "$COUNT" -ge "$MAX_FIX_ATTEMPTS" ]; then
      echo "true"
      exit 0
    else
      echo "false"
      exit 0
    fi
    ;;

  bump)
    # 失败次数 +1
    COUNT=$(get_count)
    NEW_COUNT=$((COUNT + 1))
    echo "$NEW_COUNT" > "$COUNTER_FILE"
    echo "$NEW_COUNT"
    ;;

  remaining)
    # 返回剩余可用修复次数
    COUNT=$(get_count)
    REMAINING=$((MAX_FIX_ATTEMPTS - COUNT))
    if [ "$REMAINING" -lt 0 ]; then
      REMAINING=0
    fi
    echo "$REMAINING"
    ;;

  *)
    echo "❌ 未知动作: $ACTION"
    echo "用法: bash auto-fix-loop-counter.sh <count|reset|check|bump|remaining> [工作目录]"
    exit 1
    ;;
esac