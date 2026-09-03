#!/bin/bash
# GitHub の既存本文 (PR / Issue description、コメント) を丸ごと差し替える gh 呼び出しを
# ブロックする PreToolUse フック (rules/github-writing.md「既存本文の更新」の機械的強制)。
# 対象: gh pr/issue edit、gh pr/issue comment --edit-last、gh api の PATCH で
# 本文をインライン (--body / -b / -f body=)、stdin (--body-file - / -F - / --input -)、
# process substitution で渡すもの。ファイル渡し (--body-file f / -F body=@f) と
# 新規作成 (create、新規 comment) は素通しする。Bash 経路だけが対象で、
# GitHub MCP の書き込みツールは見ていない。差分編集そのものも hook では検証できない。
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')

echo "$CMD" | grep -q 'gh' || exit 0

# 1 コマンドずつ判定する。区切り (; && || | &、改行) で分割し、引用文字列の中身は
# 空にして、--title "fix -b flag" のような引用内の文字を誤検知しない。
# heredoc 本文は改行以降に来るので、先頭行のフラグ列だけが検査対象になる。
segments=$(printf '%s\n' "$CMD" | perl -pe 's/"(?:[^"\\]|\\.)*"/""/g; s/'"'"'[^'"'"']*'"'"'/""/g; s/\|\||&&|;|\||&/\n/g')

block() { echo "$1" >&2; exit 2; }

while IFS= read -r seg; do
  echo "$seg" | grep -qE '^\s*gh\s' || continue

  target=""
  if echo "$seg" | grep -qE '^\s*gh\s+(\S+\s+)*(pr|issue)\s+(\S+\s+)*edit(\s|$)'; then
    target=edit
  elif echo "$seg" | grep -qE '^\s*gh\s+(\S+\s+)*(pr|issue)\s+(\S+\s+)*comment(\s|$)' && \
       echo "$seg" | grep -qE -- '(\s)--edit-last(\s|$)'; then
    target=edit
  elif echo "$seg" | grep -qE '^\s*gh\s+(\S+\s+)*api(\s|$)' && \
       echo "$seg" | grep -qE -- '(-X|--method)(\s+|=)PATCH' && \
       echo "$seg" | grep -qE '(issues|pulls|comments)'; then
    target=api
  fi
  [ -n "$target" ] || continue

  if [ "$target" = edit ]; then
    if echo "$seg" | grep -qE -- '(^|\s)--body(=|\s|$)|(^|\s)-b([^-]|$)'; then
      block "Blocked: 既存本文をインライン --body / -b で差し替えない。現在値を gh ... view --json body --jq .body でファイルに取り、変更箇所だけ編集して差分をユーザーに見せ、承認後に --body-file <file> で渡す (rules/github-writing.md)"
    fi
    if echo "$seg" | grep -qE -- '(^|\s)(--body-file|-F)(=|\s+)(-(\s|$)|<\()'; then
      block "Blocked: 既存本文を stdin / heredoc / process substitution で流し込まない。現在値をファイルに取り、変更箇所だけ編集して --body-file <file> で渡す (rules/github-writing.md)"
    fi
  else
    if echo "$seg" | grep -qE -- '(^|\s)(-f|--raw-field|-F|--field)(=|\s+)body=' && \
       ! echo "$seg" | grep -qE -- '(^|\s)(-F|--field)(=|\s+)body=@'; then
      block "Blocked: gh api PATCH で本文をインライン -f body= で差し替えない。現在値を gh api ... --jq .body でファイルに取り、変更箇所だけ編集して -F body=@<file> で渡す (rules/github-writing.md)"
    fi
    if echo "$seg" | grep -qE -- '(^|\s)--input(=|\s+)(-(\s|$)|<\()'; then
      block "Blocked: gh api PATCH の本文を stdin で流し込まない。ファイルに取って局所編集し -F body=@<file> で渡す (rules/github-writing.md)"
    fi
  fi
done <<< "$segments"

exit 0
