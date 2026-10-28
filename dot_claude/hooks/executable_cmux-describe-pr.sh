#!/usr/bin/env bash
# PostToolUse (Bash) hook: `gh pr create` の直後に、cmux workspace の
# description を PR タイトルにする。
#
# 失敗しても Claude の動作を妨げないよう、常に exit 0・出力なしで終える。
set -uo pipefail

describe_pr="${HOME}/.config/cmux/scripts/describe-pr.sh"

input=$(cat) || exit 0
command=$(printf '%s' "${input}" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[[ "${command}" == *"gh pr create"* ]] || exit 0

cwd=$(printf '%s' "${input}" | jq -r '.cwd // empty' 2>/dev/null) || exit 0
[[ -n "${cwd}" && -d "${cwd}" && -x "${describe_pr}" ]] || exit 0

# Why: gh pr create は別リポの worktree で走ることがあり、その cwd の branch には
# PR が無い。出力の PR URL を渡して、cwd に依存せず PR を特定する。
output=$(printf '%s' "${input}" | jq -r '.tool_response | if type == "object" then (.stdout // empty) else . // empty end' 2>/dev/null) || output=""
pr_url=$(printf '%s' "${output}" | grep -Eo 'https://github\.com/[^/[:space:]]+/[^/[:space:]]+/pull/[0-9]+' | head -n 1) || pr_url=""

if [[ -n "${pr_url}" ]]; then
  (cd "${cwd}" && "${describe_pr}" --url "${pr_url}") >/dev/null 2>&1 || true
else
  (cd "${cwd}" && "${describe_pr}") >/dev/null 2>&1 || true
fi
exit 0
