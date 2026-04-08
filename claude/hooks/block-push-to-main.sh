#!/bin/bash
# master/main ブランチへの push をブロックする PreToolUse フック
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')

# git push コマンドでなければスキップ
echo "$CMD" | grep -qE '^\s*git\s+push' || exit 0

# 明示的に main/master が指定されている場合
if echo "$CMD" | grep -qE '\s(main|master)(\s|$)'; then
  echo "Blocked: push to main/master is not allowed: $CMD" >&2
  exit 2
fi

# 引数なし or リモート名のみの push → 現在のブランチを確認
if echo "$CMD" | grep -qE '^\s*git\s+push\s*$' || \
   echo "$CMD" | grep -qE '^\s*git\s+push\s+(-[a-zA-Z]+\s+)*[a-zA-Z0-9_.-]+\s*$'; then
  CURRENT=$(git branch --show-current 2>/dev/null)
  if [ "$CURRENT" = "main" ] || [ "$CURRENT" = "master" ]; then
    echo "Blocked: currently on $CURRENT — push to main/master is not allowed" >&2
    exit 2
  fi
fi

exit 0
