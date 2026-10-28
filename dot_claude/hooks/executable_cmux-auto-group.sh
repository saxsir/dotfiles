#!/usr/bin/env bash
# SessionStart hook、および cmux-describe-pr.sh から呼ぶ。cmux の workspace の
# 自動グループ分け (auto-group.sh --once) を裏で 1 回走らせる。
#
# session の起動を待たせないよう、裏で切り離して即座に返る。失敗しても Claude の
# 動作を妨げないよう、常に exit 0・出力なしで終える。
set -uo pipefail

auto_group="${HOME}/.config/cmux/scripts/auto-group.sh"
state_dir="${HOME}/.local/state/cmux"
lock="${state_dir}/auto-group.lock"
log="${state_dir}/auto-group.log"

cat >/dev/null 2>&1 || true

[[ -n "${CMUX_WORKSPACE_ID:-}" && -x "${auto_group}" ]] || exit 0
mkdir -p "${state_dir}" 2>/dev/null || exit 0

# Why: macOS に flock が無いので mkdir で排他する。実行が異常終了してロックが残っても
# 走らなくならないよう、10 分より古いロックは消して取り直す。
if [[ -n "$(find "${lock}" -maxdepth 0 -mmin +10 2>/dev/null)" ]]; then
  rmdir "${lock}" 2>/dev/null || true
fi

(
  mkdir "${lock}" 2>/dev/null || exit 0
  nohup "${auto_group}" --once </dev/null >>"${log}" 2>&1
  rmdir "${lock}" 2>/dev/null
) </dev/null >/dev/null 2>&1 &
exit 0
