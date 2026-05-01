#!/bin/bash
# Bash 経由での機密ファイル読み取りをブロックする PreToolUse フック
# Read の deny ルールは Bash(cat .env) 等では効かないため、このフックで補完する
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')

SENSITIVE_PATTERNS='\.env|\.pem|\.key|id_rsa|id_ed25519|credentials|secrets'

if echo "$CMD" | grep -iqE "(cat|less|more|head|tail|grep|awk|sed)\s.*(${SENSITIVE_PATTERNS})"; then
  echo "Blocked: reading sensitive file via Bash: $CMD" >&2
  exit 2
fi

exit 0
