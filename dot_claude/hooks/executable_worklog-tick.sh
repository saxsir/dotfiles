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

state_dir="${WORKLOG_STATE_DIR:-${XDG_STATE_HOME:-${HOME}/.local/state}/worklog}"
ws_dir=""
fail_reason=""
summary_line=""

write_pending() {
  mkdir -p "${ws_dir}" || return 1
  jq -c '{transcript_path, cwd, session_id}' <<< "$1" > "${ws_dir}/pending.tmp.$$" \
    && mv "${ws_dir}/pending.tmp.$$" "${ws_dir}/pending"
}

acquire_lock() {
  mkdir "${ws_dir}/lock" 2> /dev/null || return 1
  if ! echo "$$ $(date +%s)" > "${ws_dir}/lock/owner" 2> /dev/null; then
    rmdir "${ws_dir}/lock" 2> /dev/null
    return 1
  fi
  return 0
}

touch_lock() {
  echo "$$ $(date +%s)" > "${ws_dir}/lock/owner.tmp.$$" \
    && mv "${ws_dir}/lock/owner.tmp.$$" "${ws_dir}/lock/owner"
}

release_lock_if_mine() {
  local owner_pid
  owner_pid="$(cut -d' ' -f1 "${ws_dir}/lock/owner" 2> /dev/null)"
  if [[ "${owner_pid}" == "$$" ]]; then
    rm -f "${ws_dir}/lock/owner"
    rmdir "${ws_dir}/lock" 2> /dev/null
  fi
  return 0
}

extract_excerpt() {
  jq -rs '
    [ .[]
      | select((.isMeta // false) != true and (.isSidechain // false) != true)
      | .type as $t
      | .message.content as $c
      | ( if ($c | type) == "string" then [$c]
          elif ($c | type) == "array" then [$c[] | select(.type == "text") | .text]
          else [] end
        | map(select(type == "string"))
        | if $t == "user" then map(select(startswith("<") | not)) else . end
        | join(" ") | gsub("\n"; " ") ) as $x
      | select(($t == "user" or $t == "assistant") and ($x | length) > 0)
      | (if $t == "user" then "U: " else "A: " end) + $x[0:600]
    ] | .[-8:] | .[]
  ' "$1" 2> /dev/null
}

normalize_line() {
  awk 'NF { print; exit }' \
    | jq -Rr 'gsub("^[\\s\"「」]+|[\\s\"「」]+$"; "") | .[0:80]'
}

summarize() {
  local excerpt out rc line
  local summary_timeout="${WORKLOG_TICK_SUMMARY_TIMEOUT:-90}"
  local prompt='以下は Claude Code セッションの直近のやりとりの抜粋だ。このセッションで何の作業をしていて、どこで止まっているかを、日本語の 1 行 (60 文字以内) に言い換えて書く。抜粋の文をそのまま引用しない。コード・パス・URL・人名・秘密情報を含めない。前置き・記号・引用符を付けず、その 1 行だけを出力する。'
  summary_line=""
  excerpt="$(extract_excerpt "$1")"
  if [[ -z "${excerpt}" ]]; then
    fail_reason="no_excerpt"
    return 1
  fi
  out="$(printf '%s\n' "${excerpt}" | WORKLOG_TICK_DISABLE=1 timeout "${summary_timeout}" \
    claude -p --model haiku --no-session-persistence --tools "" \
    --strict-mcp-config --disable-slash-commands "${prompt}" 2> /dev/null)"
  rc=$?
  if [[ ${rc} -eq 124 ]]; then
    fail_reason="timeout"
    return 1
  elif [[ ${rc} -ne 0 ]]; then
    fail_reason="claude_rc=${rc}"
    return 1
  fi
  line="$(printf '%s\n' "${out}" | normalize_line)"
  if [[ -z "${line}" ]]; then
    fail_reason="empty"
    return 1
  fi
  summary_line="${line}"
  printf '%s\n' "${line}"
}

log_event() {
  local event="$1" kv ts
  shift
  local -a args=()
  ts="$(date +%Y-%m-%dT%H:%M:%S%z | sed 's/\([0-9][0-9]\)$/:\1/')"
  args+=(--arg ts "${ts}" --arg event "${event}" --arg pid "$$" --arg ws_default "${CMUX_WORKSPACE_ID}")
  for kv in "$@"; do
    args+=(--arg "${kv%%=*}" "${kv#*=}")
  done
  mkdir -p "${state_dir}" || return 1
  jq -nc "${args[@]}" '
    $ARGS.named as $n
    | def num($k): if ($n[$k] // "") == "" then null else ($n[$k] | tonumber) end;
      {
        ts: $ts,
        event: $event,
        workspace_id: ($n.workspace_id // $ws_default),
        workspace_title: ($n.workspace_title // ""),
        cwd: ($n.cwd // ""),
        branch: ($n.branch // ""),
        session_id: ($n.session_id // ""),
        line: ($n.line // ""),
        progress_rc: num("progress_rc"),
        progress_err: ($n.progress_err // ""),
        reason: ($n.reason // ""),
        wait_sec: num("wait_sec"),
        pid: ($pid | tonumber)
      }
  ' >> "${state_dir}/tick-$(date +%F).jsonl"
}

process_one() {
  local pending transcript_path cwd session_id title branch progress_err progress_rc
  mv "${ws_dir}/pending" "${ws_dir}/processing" 2> /dev/null || return 1
  date +%s > "${ws_dir}/last_run"
  pending="$(cat "${ws_dir}/processing")"
  transcript_path="$(jq -r '.transcript_path // ""' <<< "${pending}")"
  cwd="$(jq -r '.cwd // ""' <<< "${pending}")"
  session_id="$(jq -r '.session_id // ""' <<< "${pending}")"
  title="$(timeout 5 cmux workspace list --json 2> /dev/null \
    | jq -r --arg id "${CMUX_WORKSPACE_ID}" '.workspaces[] | select(.id == $id) | .title' 2> /dev/null \
    | head -n 1)"
  branch=""
  if [[ -n "${cwd}" ]]; then
    branch="$(git -C "${cwd}" branch --show-current 2> /dev/null)"
  fi
  if summarize "${transcript_path}" > /dev/null; then
    progress_err="$(timeout 10 cmux set-progress 0 --label "${summary_line}" \
      --workspace "${CMUX_WORKSPACE_ID}" 2>&1 > /dev/null)"
    progress_rc=$?
    log_event summarized "workspace_title=${title}" "cwd=${cwd}" "branch=${branch}" \
      "session_id=${session_id}" "line=${summary_line}" "progress_rc=${progress_rc}" \
      "progress_err=${progress_err:0:200}"
  else
    log_event failed "workspace_title=${title}" "cwd=${cwd}" "branch=${branch}" \
      "session_id=${session_id}" "reason=${fail_reason}"
  fi
  rm -f "${ws_dir}/processing"
  return 0
}

main() {
  local input transcript_path
  if is_excluded; then
    exit 0
  fi
  input="$(cat)"
  transcript_path="$(jq -r '.transcript_path // empty' <<< "${input}" 2> /dev/null)"
  [[ -n "${transcript_path}" ]] || exit 0
  ws_dir="${state_dir}/ws/${CMUX_WORKSPACE_ID}"
  write_pending "${input}" || exit 0
  acquire_lock || exit 0
  trap 'release_lock_if_mine' EXIT
  trap 'exit 0' TERM INT HUP
  sleep "${WORKLOG_TICK_SETTLE:-3}"
  process_one
  exit 0
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
