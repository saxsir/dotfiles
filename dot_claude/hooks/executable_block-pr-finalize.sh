#!/bin/bash
# PR の ready 化 / merge をブロックする PreToolUse フック
# (rules/role-separation.md「対外的な締めはユーザー」の機械的強制。
#  permissions.deny の prefix マッチは gh の global flag 挿入や
#  gh api 経由をすり抜けるため、hook 側でも防ぐ)
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')

# コマンド先頭またはシェル区切り直後の gh 呼び出しのみ対象
# (commit message 等の文字列中の "gh pr ready" を誤ブロックしない)
echo "$CMD" | grep -qE '(^|;|&|\|)\s*gh\s' || exit 0

# gh [global flags] pr [flags] ready|merge (フラグの位置を問わない)
if echo "$CMD" | grep -qE '(^|;|&|\|)\s*gh\s+(\S+\s+)*pr\s+(\S+\s+)*(ready|merge)([^a-zA-Z-]|$)'; then
  echo "Blocked: gh pr ready/merge はユーザーが実行する (rules/role-separation.md)" >&2
  exit 2
fi

# gh api 経由の merge / ready 化 (REST の pulls/*/merge, GraphQL mutation)
if echo "$CMD" | grep -qE '(^|;|&|\|)\s*gh\s+(\S+\s+)*api\s' && \
   echo "$CMD" | grep -qiE '(pulls/[^ ]*/merge|mergePullRequest|markPullRequestReadyForReview)'; then
  echo "Blocked: gh api 経由の PR merge/ready 化はユーザーが実行する (rules/role-separation.md)" >&2
  exit 2
fi

exit 0
