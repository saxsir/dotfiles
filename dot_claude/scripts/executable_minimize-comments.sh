#!/bin/bash
# PR / Issue のコメントを OUTDATED として折りたたむ (rules/github-workflow.md)。
# usage: minimize-comments.sh <owner> <repo> <comment-id> [comment-id...]
# comment-id は issue comment の数値 id (URL 末尾の issuecomment-<id>)。
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "usage: $0 <owner> <repo> <comment-id> [comment-id...]" >&2
  exit 1
fi

owner="${1}"
repo="${2}"
shift 2

status=0
for comment_id in "$@"; do
  node_id=$(gh api "repos/${owner}/${repo}/issues/comments/${comment_id}" --jq .node_id) || { status=1; continue; }
  # gh api graphql はエラー時も exit 0 を返すので .errors を見る
  res=$(gh api graphql \
    -f query='mutation($id: ID!) { minimizeComment(input: {subjectId: $id, classifier: OUTDATED}) { minimizedComment { isMinimized } } }' \
    -f id="${node_id}")
  if echo "${res}" | jq -e '.errors' >/dev/null; then
    echo "FAIL ${comment_id}: $(echo "${res}" | jq -c '.errors')" >&2
    status=1
  else
    echo "MINIMIZED ${comment_id}"
  fi
done
exit "${status}"
