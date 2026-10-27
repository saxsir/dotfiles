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
