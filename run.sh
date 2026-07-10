#!/bin/bash
# 🏛️ 五人决策小组 — 一键启动
#
# 用法:
#   ./run.sh                          # 用 problem.json 里的内容跑
#   ./run.sh "你的决策难题..."         # 直接传入问题
#   ./run.sh --file path/to/file.json # 指定输入文件
#   ./run.sh --chat                   # 对话模式（一问一答，不用跑流水线）

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PIPELINE="$SCRIPT_DIR/pipeline.yaml"
SYSTEM_PROMPT_FILE="$SCRIPT_DIR/system-prompt.md"

# ── 对话模式 ──────────────────────────────────────
if [ "$1" = "--chat" ]; then
  SYSTEM_PROMPT=$(cat "$SYSTEM_PROMPT_FILE")
  bl text chat \
    --model qwen3.7-max \
    --max-tokens 8192 \
    --system "$SYSTEM_PROMPT" \
    --message "你好，我有一个职场决策难题，想请各位决策者帮我梳理。我先描述一下情况。"
  exit $?
fi

# ── 指定输入文件 ──────────────────────────────────
if [ "$1" = "--file" ] && [ -n "$2" ]; then
  bl pipeline run "$PIPELINE" --input-file "$2" --output json
  exit $?
fi

# ── 直接传入问题文字 ──────────────────────────────
if [ $# -gt 0 ]; then
  PROBLEM="$*"
  bl pipeline run "$PIPELINE" \
    --input "{\"problem\":\"$(echo "$PROBLEM" | sed 's/"/\\"/g')}\"" \
    --output json
  exit $?
fi

# ── 默认：用 problem.json ─────────────────────────
INPUT_FILE="$SCRIPT_DIR/problem.json"
if [ ! -f "$INPUT_FILE" ]; then
  echo "❌ 找不到 $INPUT_FILE，请提供问题：./run.sh \"你的决策难题\""
  exit 1
fi
bl pipeline run "$PIPELINE" --input-file "$INPUT_FILE" --output json
