#!/bin/bash
# セッション終了時に claude-md-improver 実行を促す Stop hook
# session_id ベースのセンチネルで1セッションにつき1回だけ発火
SESSION_ID=$(jq -r '.session_id // empty')
if [ -z "$SESSION_ID" ]; then
  echo '{}'
  exit 0
fi

SENTINEL="${TMPDIR:-/tmp}/claude-md-improver-${SESSION_ID}"
if [ -f "$SENTINEL" ]; then
  echo '{}'
  exit 0
fi

touch "$SENTINEL"
cat <<'EOF'
{
  "decision": "block",
  "reason": "セッション終了前にCLAUDE.mdを更新します",
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "【自動ルーチン】セッション終了前に /claude-md-management:claude-md-improver を実行し、このセッションでの学びをCLAUDE.mdに反映してください。完了したらセッションを終了してください。"
  }
}
EOF
