#!/bin/bash
# セッション終了時に retrospective-codify 実行を促す Stop hook
# session_id ベースのセンチネルで1セッションにつき1回だけ発火
#
# NOTE: Stop hook の出力 JSON で hookSpecificOutput.additionalContext は
# 使えない（UserPromptSubmit / PostToolUse / PostToolBatch 専用）。
# Claude への指示は decision: block + reason に直接書く。
SESSION_ID=$(jq -r '.session_id // empty')
if [ -z "$SESSION_ID" ]; then
  echo '{}'
  exit 0
fi

SENTINEL="${TMPDIR:-/tmp}/claude-retrospective-${SESSION_ID}"
if [ -f "$SENTINEL" ]; then
  echo '{}'
  exit 0
fi

touch "$SENTINEL"
cat <<'EOF'
{
  "decision": "block",
  "reason": "【自動ルーチン】セッション終了前に retrospective-codify skill を実行し、このセッションの学びを ast-grep ルール / skill / CLAUDE.md(rules) のいずれかに反映してください。提案ゼロも妥当な結論です。完了したらセッションを終了してください。"
}
EOF
