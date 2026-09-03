#!/bin/bash
# GitHub の既存本文 (PR / Issue description、コメント) をインラインの --body で
# 丸ごと差し替える gh 呼び出しをブロックする PreToolUse フック
# (rules/github-writing.md「既存本文の更新」の機械的強制)。
# 新規作成 (create / comment の新規投稿) は対象外。--body-file は素通しする。
# 現在値をファイルに取り、局所編集して --body-file で渡す流れに寄せるのが目的で、
# 差分編集そのものは hook では検証できない。
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')

echo "$CMD" | grep -qE '(^|;|&|\|)\s*gh\s' || exit 0

# 既存本文を更新するサブコマンド: gh [flags] (pr|issue) [flags] edit / comment --edit-last
is_edit=false
if echo "$CMD" | grep -qE '(^|;|&|\|)\s*gh\s+(\S+\s+)*(pr|issue)\s+(\S+\s+)*edit([^a-zA-Z-]|$)'; then
  is_edit=true
elif echo "$CMD" | grep -qE '(^|;|&|\|)\s*gh\s+(\S+\s+)*(pr|issue)\s+(\S+\s+)*comment(\s|$)' && \
     echo "$CMD" | grep -qE -- '--edit-last'; then
  is_edit=true
fi
[ "$is_edit" = true ] || exit 0

# インライン本文 (--body / --body= / -b) があればブロック。--body-file は許可
if echo "$CMD" | grep -qE -- '(\s|^)(--body(=|\s)|-b\s)'; then
  echo "Blocked: 既存本文をインライン --body で差し替えない。現在値を gh ... view --json body --jq .body でファイルに取り、変更箇所だけ編集して差分をユーザーに見せ、承認後に --body-file で渡す (rules/github-writing.md)" >&2
  exit 2
fi

exit 0
