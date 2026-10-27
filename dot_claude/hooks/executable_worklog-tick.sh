#!/usr/bin/env bash
# Stop hook (async)。cmux workspace の現在地を 1 行にして表示し tick ログに残す。
# 非同期は settings.json の "async": true だけで得る。script 自身は background 化しない。
set -uo pipefail

# 親と祖父の 2 段までで、claude が -p / --print 付きで動いているかを見る。
# 3 段以上たどると、Claude Code の中で走らせたテストの祖先に実行者の claude が現れる。
is_headless() {
  local pid="${PPID}" args first token base
  for _ in 1 2; do
    [[ -n "${pid}" && "${pid}" -gt 1 ]] 2> /dev/null || return 1
    args="$(ps -o args= -p "${pid}" 2> /dev/null)"
    first="${args%% *}"
    base="${first##*/}"
    if [[ "${base}" == "claude" ]]; then
      for token in ${args}; do
        if [[ "${token}" == "-p" || "${token}" == "--print" ]]; then
          return 0
        fi
      done
    fi
    pid="$(ps -o ppid= -p "${pid}" 2> /dev/null | tr -d ' ')"
  done
  return 1
}

is_excluded() {
  [[ -z "${CMUX_WORKSPACE_ID:-}" ]] && return 0
  [[ -n "${WORKLOG_TICK_DISABLE:-}" ]] && return 0
  [[ "${CMUX_WORKSPACE_ID}" == */* || "${CMUX_WORKSPACE_ID}" == *..* ]] && return 0
  is_headless && return 0
  return 1
}

main() {
  if is_excluded; then
    exit 0
  fi
  cat > /dev/null
  exit 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
