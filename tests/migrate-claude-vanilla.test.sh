#!/usr/bin/env bash
# misc/bin/migrate-claude-vanilla.sh のテスト。一時ディレクトリに vanilla と main を作って流すので、本物の ~/ には触らない。
# 使い方: bash tests/migrate-claude-vanilla.test.sh [test_name ...]
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="${repo_root}/misc/bin/migrate-claude-vanilla.sh"

fail() {
  echo "  FAIL: $*" >&2
  exit 1
}

setup() {
  tmp="$(mktemp -d)"
  trap 'rm -rf "${tmp}"' EXIT
  export VANILLA_DIR="${tmp}/vanilla"
  export MAIN_DIR="${tmp}/main"
  export SKIP_RUNNING_CHECK=1
  mkdir -p "${VANILLA_DIR}/projects/-p1/s1" "${VANILLA_DIR}/projects/-p1/memory" \
    "${VANILLA_DIR}/projects/-p2/memory" \
    "${MAIN_DIR}/projects/-p1/memory" "${MAIN_DIR}/projects/-p3"
  echo v-s1 > "${VANILLA_DIR}/projects/-p1/s1.jsonl"
  echo v-sub > "${VANILLA_DIR}/projects/-p1/s1/agent.jsonl"
  echo v-mem > "${VANILLA_DIR}/projects/-p1/memory/MEMORY.md"
  echo v-mem2 > "${VANILLA_DIR}/projects/-p2/memory/MEMORY.md"
  echo m-mem > "${MAIN_DIR}/projects/-p1/memory/MEMORY.md"
  echo m-only > "${MAIN_DIR}/projects/-p1/memory/old.md"
  echo m-s3 > "${MAIN_DIR}/projects/-p3/s3.jsonl"
  echo notes > "${VANILLA_DIR}/NOTES.md"
  printf '%s\n' '{"display":"v1","timestamp":2}' '{"display":"v2","timestamp":4}' > "${VANILLA_DIR}/history.jsonl"
  # main の最終行は改行で終わらない
  printf '%s\n%s' '{"display":"m1","timestamp":1}' '{"display":"m2","timestamp":3}' > "${MAIN_DIR}/history.jsonl"
}

migrate() {
  bash "${script}" "$@" > "${tmp}/out" 2>&1 || fail "script failed: $(cat "${tmp}/out")"
}

snapshot() {
  (cd "${tmp}" && find . -type f ! -name out -print0 | sort -z | xargs -0 shasum)
}

test_migrates_sessions_memory_history_notes() {
  setup
  migrate
  [[ "$(cat "${MAIN_DIR}/projects/-p1/s1.jsonl")" == v-s1 ]] || fail "session not copied"
  [[ "$(cat "${MAIN_DIR}/projects/-p1/s1/agent.jsonl")" == v-sub ]] || fail "session dir not copied"
  [[ "$(cat "${MAIN_DIR}/projects/-p3/s3.jsonl")" == m-s3 ]] || fail "main session lost"
  [[ "$(cat "${MAIN_DIR}/projects/-p1/memory/MEMORY.md")" == v-mem ]] || fail "vanilla memory not taken"
  [[ ! -e "${MAIN_DIR}/projects/-p1/memory/old.md" ]] || fail "main memory not replaced"
  [[ "$(cat "${MAIN_DIR}/vanilla-migration-backup/projects/-p1/memory/MEMORY.md")" == m-mem ]] || fail "main memory not backed up"
  [[ -e "${MAIN_DIR}/vanilla-migration-backup/projects/-p1/memory/old.md" ]] || fail "main memory not backed up whole"
  [[ "$(cat "${MAIN_DIR}/projects/-p2/memory/MEMORY.md")" == v-mem2 ]] || fail "new memory not copied"
  [[ "$(cat "${MAIN_DIR}/NOTES.md")" == notes ]] || fail "NOTES.md not copied"
  local displays
  displays="$(jq -r .display "${MAIN_DIR}/history.jsonl" | tr '\n' ' ')"
  [[ "${displays}" == "m1 v1 m2 v2 " ]] || fail "history not merged in order: ${displays}"
  [[ "$(cat "${MAIN_DIR}/vanilla-migration-backup/history.jsonl")" == "$(printf '%s\n%s' '{"display":"m1","timestamp":1}' '{"display":"m2","timestamp":3}')" ]] \
    || fail "history not backed up"
  [[ -f "${VANILLA_DIR}/history.jsonl" && -f "${VANILLA_DIR}/projects/-p1/s1.jsonl" ]] || fail "vanilla modified"
}

test_second_run_changes_nothing() {
  setup
  migrate
  local before
  before="$(snapshot)"
  migrate
  [[ "$(snapshot)" == "${before}" ]] || fail "second run changed files"
}

test_rerun_after_main_changed_keeps_main() {
  setup
  migrate
  echo m-new > "${MAIN_DIR}/projects/-p2/memory/MEMORY.md"
  echo s1-appended >> "${MAIN_DIR}/projects/-p1/s1.jsonl"
  local before
  before="$(snapshot)"
  migrate
  [[ "$(snapshot)" == "${before}" ]] || fail "rerun reverted main"
}

test_nested_memory_dir_in_session_is_copied() {
  setup
  mkdir -p "${VANILLA_DIR}/projects/-p1/s1/memory"
  echo nested > "${VANILLA_DIR}/projects/-p1/s1/memory/x.md"
  migrate
  [[ "$(cat "${MAIN_DIR}/projects/-p1/s1/memory/x.md")" == nested ]] || fail "nested memory dir skipped"
}

test_no_vanilla_dir_is_noop() {
  setup
  rm -rf "${VANILLA_DIR}"
  local before
  before="$(snapshot)"
  migrate
  [[ "$(snapshot)" == "${before}" ]] || fail "changed files without vanilla"
}

test_differing_file_is_backed_up_before_overwrite() {
  setup
  echo m-notes > "${MAIN_DIR}/NOTES.md"
  migrate
  [[ "$(cat "${MAIN_DIR}/NOTES.md")" == notes ]] || fail "NOTES.md not overwritten"
  [[ "$(cat "${MAIN_DIR}/vanilla-migration-backup/NOTES.md")" == m-notes ]] || fail "NOTES.md not backed up"
}

test_existing_backup_is_never_overwritten() {
  setup
  migrate
  rm "${MAIN_DIR}/.vanilla-migrated"
  echo m-new > "${MAIN_DIR}/projects/-p1/memory/MEMORY.md"
  local backup_before
  backup_before="$(cat "${MAIN_DIR}/vanilla-migration-backup/projects/-p1/memory/MEMORY.md")"
  if bash "${script}" > "${tmp}/out" 2>&1; then
    fail "should stop when backup exists"
  fi
  [[ "$(cat "${MAIN_DIR}/vanilla-migration-backup/projects/-p1/memory/MEMORY.md")" == "${backup_before}" ]] \
    || fail "backup overwritten"
  [[ "$(cat "${MAIN_DIR}/projects/-p1/memory/MEMORY.md")" == m-new ]] || fail "main memory clobbered"
}

test_dry_run_changes_nothing() {
  setup
  local before
  before="$(snapshot)"
  migrate --dry-run
  [[ "$(snapshot)" == "${before}" ]] || fail "dry-run changed files"
}

tests=("$@")
if [[ $# -eq 0 ]]; then
  while IFS= read -r t; do
    tests+=("${t}")
  done < <(declare -F | awk '{print $3}' | grep '^test_')
fi

status=0
for t in "${tests[@]}"; do
  if (${t}); then
    echo "ok: ${t}"
  else
    echo "not ok: ${t}"
    status=1
  fi
done
exit "${status}"
