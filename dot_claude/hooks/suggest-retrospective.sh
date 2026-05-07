#!/bin/bash
# セッション終了時に retrospective-codify 実行を促す Stop hook
# session_id ベースのセンチネルで1セッションにつき1回だけ発火
#
# NOTE: Stop hook の出力 JSON で hookSpecificOutput.additionalContext は
# 使えない（UserPromptSubmit / PostToolUse / PostToolBatch 専用）。
# Claude への指示は decision: block + reason に直接書く。
INPUT=$(cat)
SESSION_ID=$(jq -r '.session_id // empty' <<<"$INPUT")
TRANSCRIPT=$(jq -r '.transcript_path // empty' <<<"$INPUT")
if [ -z "$SESSION_ID" ]; then
  echo '{}'
  exit 0
fi

SENTINEL="${TMPDIR:-/tmp}/claude-retrospective-${SESSION_ID}"
if [ -f "$SENTINEL" ]; then
  echo '{}'
  exit 0
fi

# Stop hook は plan mode 終了 / /compact / /clear でも発火する。
# 直近の tool_use が ExitPlanMode なら、計画承認直後の Stop と判断して suppress。
# センチネルは作らない: 後続の通常ターン終了で改めて発火させたい。
# /compact /clear の痕跡は未調査 (TODO).
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  last_tool=$(tac "$TRANSCRIPT" 2>/dev/null \
    | jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use") | .name' 2>/dev/null \
    | head -1)
  if [ "$last_tool" = "ExitPlanMode" ]; then
    echo '{}'
    exit 0
  fi
fi

touch "$SENTINEL"
cat <<'EOF'
{
  "decision": "block",
  "reason": "【自動ルーチン】セッション終了前に retrospective-codify skill を実行し、このセッションの学びを ast-grep ルール / skill / CLAUDE.md(rules) のいずれかに反映してください。提案ゼロも妥当な結論です。完了したらセッションを終了してください。"
}
EOF
