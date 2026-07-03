#!/bin/bash
# PR の merge をブロックし、ready 化は正規形のみ permission prompt に委ねる
# PreToolUse フック (rules/role-separation.md の機械的強制)。
# permissions の prefix マッチは gh の global flag 挿入 (gh -R x pr merge) や
# gh api 経由をすり抜けるため、hook 側で全形態を捕捉する。
# ready は ask ルール Bash(gh pr ready:*) がプロンプトを出せる正規形だけを
# 素通しし、ask が捕捉できない迂回形は正規形での再実行を促してブロックする。
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')

# コマンド先頭またはシェル区切り直後の gh 呼び出しのみ対象
# (commit message 等の文字列中の "gh pr merge" を誤ブロックしない)
echo "$CMD" | grep -qE '(^|;|&|\|)\s*gh\s' || exit 0

# merge は全形態ブロック (gh [global flags] pr [flags] merge)
if echo "$CMD" | grep -qE '(^|;|&|\|)\s*gh\s+(\S+\s+)*pr\s+(\S+\s+)*merge([^a-zA-Z-]|$)'; then
  echo "Blocked: gh pr merge はユーザーが実行する (rules/role-separation.md)" >&2
  exit 2
fi

# gh api 経由の merge / ready 化 (REST の pulls/*/merge, GraphQL mutation)
if echo "$CMD" | grep -qE '(^|;|&|\|)\s*gh\s+(\S+\s+)*api\s' && \
   echo "$CMD" | grep -qiE '(pulls/[^ ]*/merge|mergePullRequest|markPullRequestReadyForReview)'; then
  echo "Blocked: gh api 経由の PR merge/ready 化は不可。ready 化は gh pr ready <n> の正規形で (承認プロンプトが出る)" >&2
  exit 2
fi

# ready: 正規形 (gh pr ready ...) は ask ルールに委ねて素通し
echo "$CMD" | grep -qE '(^|;|&|\|)\s*gh\s+pr\s+ready(\s|$|;|&)' && exit 0

# ready の迂回形 (gh -R owner/repo pr ready 等) は ask がマッチしないためブロック
if echo "$CMD" | grep -qE '(^|;|&|\|)\s*gh\s+(\S+\s+)*pr\s+(\S+\s+)*ready([^a-zA-Z-]|$)'; then
  echo "Blocked: gh pr ready <n> の正規形で再実行する (承認プロンプトが出る)" >&2
  exit 2
fi

exit 0
