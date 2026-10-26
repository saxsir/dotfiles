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

(cd "${cwd}" && "${describe_pr}") >/dev/null 2>&1 || true
exit 0
