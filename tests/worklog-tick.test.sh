#!/usr/bin/env bash
# worklog-tick.sh のテスト。使い方: bash tests/worklog-tick.test.sh [test_name ...]
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="${repo_root}/dot_claude/hooks/executable_worklog-tick.sh"

fail() {
  echo "  FAIL: $*" >&2
  exit 1
}

assert_eq() {
  [[ "$1" == "$2" ]] || fail "$3 (expected: '$1', actual: '$2')"
}

assert_file_absent() {
  [[ ! -e "$1" ]] || fail "exists: $1"
}

assert_contains() {
  [[ "$1" == *"$2"* ]] || fail "'$2' not found in: $1"
}

assert_not_contains() {
  [[ "$1" != *"$2"* ]] || fail "'$2' unexpectedly found in: $1"
}

write_stub_claude() {
  cat > "${tmp}/bin/claude" <<'STUB'
#!/usr/bin/env bash
dir="$(dirname "$0")/.."
{ echo "--- call ---"; printf '%s\n' "$@"; } >> "${dir}/claude.args"
{ echo "--- call ---"; cat; } >> "${dir}/claude.stdin"
echo "${WORKLOG_TICK_DISABLE-}" >> "${dir}/claude.env"
date +%s >> "${dir}/claude.count"
sleep "${STUB_CLAUDE_SLEEP:-0}"
echo "${STUB_CLAUDE_OUT:-テスト用の要約}"
exit "${STUB_CLAUDE_RC:-0}"
STUB
  chmod +x "${tmp}/bin/claude"
}

write_stub_cmux() {
  cat > "${tmp}/bin/cmux" <<'STUB'
#!/usr/bin/env bash
dir="$(dirname "$0")/.."
if [[ "$1" == "workspace" && "$2" == "list" ]]; then
  rc="${STUB_CMUX_LIST_RC:-0}"
  if [[ "${rc}" != "0" ]]; then
    exit "${rc}"
  fi
  printf '{"workspaces":[{"id":"ws-test","title":"%s"}]}\n' "${STUB_WS_TITLE-}"
  exit 0
fi
if [[ "$1" == "set-progress" ]]; then
  printf '%s\n' "$@" >> "${dir}/cmux.calls"
  echo "${STUB_PROGRESS_ERR-}" >&2
  exit "${STUB_PROGRESS_RC:-0}"
fi
exit 0
STUB
  chmod +x "${tmp}/bin/cmux"
}

setup_env() {
  tmp="$(mktemp -d)"
  mkdir -p "${tmp}/bin"
  export WORKLOG_STATE_DIR="${tmp}/state"
  export CMUX_WORKSPACE_ID=ws-test
  export WORKLOG_TICK_INTERVAL=600
  export WORKLOG_TICK_SUMMARY_TIMEOUT=5
  export WORKLOG_TICK_SETTLE=0
  PATH="${tmp}/bin:${PATH}"
  unset WORKLOG_TICK_DISABLE
  write_stub_claude
  write_stub_cmux
}

make_transcript() {
  local path="$1" marker="$2"
  {
    jq -cn --arg m "${marker}" '{type:"user",message:{role:"user",content:("user says " + $m)}}'
    jq -cn --arg m "${marker}" '{type:"assistant",message:{role:"assistant",content:[{type:"text",text:("assistant says " + $m)}]}}'
    jq -cn '{type:"user",message:{role:"user",content:[{type:"tool_result",tool_use_id:"t1",content:"tool output"}]}}'
    jq -cn '{type:"user",isMeta:true,message:{role:"user",content:"META_ONLY_9c1"}}'
    jq -cn '{type:"assistant",message:{role:"assistant",content:[{type:"text",text:"last text entry"}]}}'
    jq -cn '{type:"assistant",message:{role:"assistant",content:[{type:"thinking",thinking:"hmm"}]}}'
    jq -cn '{type:"assistant",message:{role:"assistant",content:[{type:"tool_use",id:"t2",name:"Bash",input:{}}]}}'
  } > "${path}"
}

hook_input() {
  jq -cn --arg t "$1" --arg c "$2" --arg s "${3:-sess-1}" \
    '{session_id:$s,transcript_path:$t,cwd:$c,hook_event_name:"Stop"}'
}

prepare_input() {
  make_transcript "${tmp}/transcript.jsonl" "MARKER_1"
  input_file="${tmp}/input.json"
  hook_input "${tmp}/transcript.jsonl" "${tmp}" > "${input_file}"
}

run_hook() {
  "${script}" < "${input_file}" > "${tmp}/stdout" 2> "${tmp}/stderr"
  rc=$?
}

# 親プロセスの argv を指定して script を起動する。argv0 は claude にする。
run_hook_under_claude() {
  bash -c 'exec -a claude bash -c "\"\$1\" < \"\$2\"; true" claude "$0" "$1" "${@:2}"' \
    "${script}" "${input_file}" "$@" > "${tmp}/stdout" 2> "${tmp}/stderr"
  rc=$?
}

assert_did_nothing() {
  assert_eq 0 "${rc}" "exit code"
  assert_eq "" "$(cat "${tmp}/stdout")" "stdout"
  assert_file_absent "${WORKLOG_STATE_DIR}"
  assert_file_absent "${tmp}/claude.count"
  assert_file_absent "${tmp}/cmux.calls"
}

tick_log() {
  cat "${WORKLOG_STATE_DIR}"/tick-*.jsonl 2>/dev/null
}

test_no_workspace_id_does_nothing() {
  setup_env
  prepare_input
  unset CMUX_WORKSPACE_ID
  run_hook
  assert_did_nothing
}

test_disable_env_does_nothing() {
  setup_env
  prepare_input
  WORKLOG_TICK_DISABLE=1 run_hook
  assert_did_nothing
}

test_headless_parent_does_nothing() {
  setup_env
  prepare_input
  run_hook_under_claude -p
  assert_did_nothing
}

test_workspace_id_with_slash_does_nothing() {
  setup_env
  prepare_input
  CMUX_WORKSPACE_ID=../x run_hook
  assert_did_nothing
}

test_headless_match_is_exact_token() {
  setup_env
  prepare_input
  run_hook_under_claude --permission-mode plan
  assert_eq 0 "${rc}" "exit code"
  [[ -d "${WORKLOG_STATE_DIR}/ws/ws-test" ]] || fail "ws/ws-test/ not created"
}

test_interactive_parent_is_not_headless() {
  setup_env
  prepare_input
  run_hook_under_claude
  assert_eq 0 "${rc}" "exit code"
  [[ -d "${WORKLOG_STATE_DIR}/ws/ws-test" ]] || fail "ws/ws-test/ not created"
}

prepare_summary() {
  setup_env
  export STUB_WS_TITLE=作業A
  work_dir="${tmp}/work"
  mkdir -p "${work_dir}"
  git -C "${work_dir}" init -q -b feat/x
  make_transcript "${tmp}/t1.jsonl" MARKER_A_7f3
  input_file="${tmp}/input.json"
  hook_input "${tmp}/t1.jsonl" "${work_dir}" > "${input_file}"
  ws_dir="${WORKLOG_STATE_DIR}/ws/ws-test"
}

assert_no_leftovers() {
  assert_file_absent "${ws_dir}/lock"
  assert_file_absent "${ws_dir}/pending"
  assert_file_absent "${ws_dir}/processing"
}

test_summarized_line_fields() {
  prepare_summary
  run_hook
  assert_eq 0 "${rc}" "exit code"
  assert_eq 1 "$(tick_log | wc -l | tr -d ' ')" "log lines"
  local log
  log="$(tick_log)"
  assert_eq summarized "$(jq -r .event <<< "${log}")" event
  assert_eq ws-test "$(jq -r .workspace_id <<< "${log}")" workspace_id
  assert_eq 作業A "$(jq -r .workspace_title <<< "${log}")" workspace_title
  assert_eq "${work_dir}" "$(jq -r .cwd <<< "${log}")" cwd
  assert_eq feat/x "$(jq -r .branch <<< "${log}")" branch
  assert_eq テスト用の要約 "$(jq -r .line <<< "${log}")" line
  assert_eq 0 "$(jq -r .progress_rc <<< "${log}")" progress_rc
  jq -e '.pid | type == "number"' <<< "${log}" > /dev/null || fail "pid not number"
  jq -e '.ts | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:]{8}[+-][0-9]{2}:[0-9]{2}$")' <<< "${log}" > /dev/null || fail "ts format: $(jq -r .ts <<< "${log}")"
  assert_eq "set-progress
0
--label
テスト用の要約
--workspace
ws-test" "$(cat "${tmp}/cmux.calls")" "cmux.calls"
  assert_no_leftovers
  [[ -f "${ws_dir}/last_run" ]] || fail "last_run missing"
}

test_progress_rc_is_recorded_on_failure() {
  prepare_summary
  STUB_PROGRESS_RC=3 STUB_PROGRESS_ERR=denied run_hook
  local log
  log="$(tick_log)"
  assert_eq summarized "$(jq -r .event <<< "${log}")" event
  assert_eq 3 "$(jq -r .progress_rc <<< "${log}")" progress_rc
  assert_eq denied "$(jq -r .progress_err <<< "${log}")" progress_err
}

test_claude_called_with_disable_env() {
  prepare_summary
  run_hook
  assert_eq 1 "$(cat "${tmp}/claude.env")" "claude env"
  local args stdin
  args="$(cat "${tmp}/claude.args")"
  assert_contains "${args}" "-p"
  assert_contains "${args}" "--model"
  assert_contains "${args}" "haiku"
  assert_contains "${args}" "--no-session-persistence"
  stdin="$(cat "${tmp}/claude.stdin")"
  assert_contains "${stdin}" MARKER_A_7f3
  assert_not_contains "${stdin}" "tool output"
  assert_not_contains "${stdin}" META_ONLY_9c1
}

test_summary_timeout_logs_failed() {
  prepare_summary
  WORKLOG_TICK_SUMMARY_TIMEOUT=1 STUB_CLAUDE_SLEEP=5 run_hook
  local log
  log="$(tick_log)"
  assert_eq failed "$(jq -r .event <<< "${log}")" event
  assert_eq timeout "$(jq -r .reason <<< "${log}")" reason
  assert_eq null "$(jq -c .progress_rc <<< "${log}")" progress_rc
  assert_file_absent "${tmp}/cmux.calls"
  assert_no_leftovers
}

test_claude_error_logs_failed() {
  prepare_summary
  STUB_CLAUDE_RC=2 run_hook
  assert_eq "claude_rc=2" "$(tick_log | jq -r .reason)" reason
}

test_empty_summary_logs_failed() {
  prepare_summary
  STUB_CLAUDE_OUT=$'\n  \n' run_hook
  assert_eq failed "$(tick_log | jq -r .event)" event
  assert_eq empty "$(tick_log | jq -r .reason)" reason
}

test_missing_transcript_logs_failed() {
  prepare_summary
  hook_input "${tmp}/nonexistent.jsonl" "${work_dir}" > "${input_file}"
  run_hook
  assert_eq failed "$(tick_log | jq -r .event)" event
  assert_eq no_excerpt "$(tick_log | jq -r .reason)" reason
  assert_file_absent "${tmp}/claude.count"
  assert_file_absent "${tmp}/cmux.calls"
  assert_no_leftovers
}

test_line_is_single_and_truncated() {
  prepare_summary
  local kanji out
  kanji="$(printf '漢%.0s' $(seq 1 100))"
  out=$'\n  "'"${kanji}"$'"\n2 行目'
  STUB_CLAUDE_OUT="${out}" run_hook
  local line expected
  line="$(tick_log | jq -r .line)"
  expected="$(printf '漢%.0s' $(seq 1 80))"
  assert_eq "${expected}" "${line}" line
  assert_not_contains "${line}" $'\n'
  assert_eq "${expected}" "$(sed -n 4p "${tmp}/cmux.calls")" "label"
}

test_title_empty_when_cmux_list_fails() {
  prepare_summary
  STUB_CMUX_LIST_RC=1 run_hook
  assert_eq "" "$(tick_log | jq -r .workspace_title)" workspace_title
  assert_eq summarized "$(tick_log | jq -r .event)" event
}

test_no_conversation_text_persisted() {
  prepare_summary
  run_hook
  if grep -rq MARKER_A_7f3 "${WORKLOG_STATE_DIR}"; then
    fail "conversation text found in state dir"
  fi
}

main() {
  local tests=("$@") name passed=0 failed=0
  if [[ ${#tests[@]} -eq 0 ]]; then
    while IFS= read -r name; do
      tests+=("${name}")
    done < <(declare -F | awk '{print $3}' | grep '^test_')
  fi
  for name in "${tests[@]}"; do
    if ( "${name}" ); then
      echo "PASS ${name}"
      passed=$((passed + 1))
    else
      echo "FAIL ${name}"
      failed=$((failed + 1))
    fi
  done
  echo "${passed} passed, ${failed} failed"
  [[ ${failed} -eq 0 ]]
}

main "$@"
