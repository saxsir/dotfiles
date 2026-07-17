#!/usr/bin/env bash
# cmux workspace group で、アンカー以外のメンバーが 0 になったグループを
# 自動的に ungroup する。
#
# Why: cmux は group メンバーシップ変化の専用イベントを emit しない
# (2026-07 時点、cmux 0.64.19 で確認)。抜けたときは workspace カテゴリの
# `workspace.reordered` が飛ぶだけで、payload に group id は含まれない。
# そのため event で個別に判定するのではなく、workspace カテゴリの何かが
# 起きるたびに `cmux workspace group list --json` を照合して
# `member_count == 1` (=アンカーしか残っていない) を ungroup する。
#
# Why-not: `delete` ではなく `ungroup`。delete はアンカー workspace 自体を
# 閉じるので、そこで動いていた session が失われる。ungroup ならアンカーは
# 通常の workspace として残る。
#
# Usage:
#   ~/.config/cmux/scripts/auto-ungroup.sh       # 前景実行
#   LOG=/tmp/cmux-auto-ungroup.log; nohup ~/.config/cmux/scripts/auto-ungroup.sh >>"$LOG" 2>&1 &
set -euo pipefail

cursor_file="${XDG_STATE_HOME:-$HOME/.local/state}/cmux/auto-ungroup.seq"
mkdir -p "$(dirname "$cursor_file")"

log() { printf '[cmux-auto-ungroup] %s %s\n' "$(date -u +%FT%TZ)" "$*" >&2; }

reconcile() {
  local groups_json refs
  groups_json=$(cmux workspace group list --json 2>/dev/null) || {
    log "group list failed"
    return 0
  }
  refs=$(printf '%s' "${groups_json}" |
    jq -r '.groups[]? | select(.member_count == 1) | .ref') || return 0
  [[ -z "${refs}" ]] && return 0
  while IFS= read -r ref; do
    [[ -z "${ref}" ]] && continue
    log "ungrouping ${ref} (only anchor remains)"
    cmux workspace group ungroup "${ref}" --json >/dev/null 2>&1 ||
      log "ungroup failed for ${ref}"
  done <<<"${refs}"
}

reconcile

cmux events \
  --category workspace \
  --no-ack --no-heartbeat \
  --cursor-file "${cursor_file}" \
  --reconnect --json |
  while IFS= read -r _line; do
    reconcile
  done
