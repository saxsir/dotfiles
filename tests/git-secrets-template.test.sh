#!/usr/bin/env bash
# 新規リポジトリに git-secrets の hook が入ることのテスト。
# chezmoi のソースを一時 HOME へ適用してから git init するので、本物の ~/ や state DB には触らない。
# 使い方: bash tests/git-secrets-template.test.sh [test_name ...]
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# secretlint に検出されないよう分割して組み立てる
fake_key="AKIA""ABCDEFGHIJKLMNOP"

fail() {
  echo "  FAIL: $*" >&2
  exit 1
}

setup_home() {
  tmp="$(mktemp -d)"
  trap 'rm -rf "${tmp}"' EXIT
  export HOME="${tmp}"
  export XDG_CONFIG_HOME="${tmp}/.config"
  printf '[data]\n  name = "test"\n  email = "test@example.com"\n' > "${tmp}/chezmoi.toml"
  chezmoi apply --source "${repo_root}" --config "${tmp}/chezmoi.toml" \
    --persistent-state "${tmp}/chezmoistate.boltdb" \
    "${tmp}/.gitconfig" "${tmp}/.git-templates" || fail "chezmoi apply failed"
}

new_repo() {
  git init -q "${tmp}/repo" || fail "git init failed"
  cd "${tmp}/repo" || fail "cd failed"
}

try_commit() {
  printf '%s\n' "$1" > file.txt
  git add file.txt
  commit_output="$(git commit -m test 2>&1)"
}

test_new_repo_blocks_secret_commit() {
  setup_home
  new_repo
  local status=0
  try_commit "aws_key = ${fake_key}" || status=$?
  [[ ${status} -eq 1 ]] || fail "expected exit 1, got ${status}: ${commit_output}"
  # git-secrets が無くても commit は exit 1 で失敗するので、理由まで確認する
  [[ "${commit_output}" == *"prohibited patterns"* ]] \
    || fail "not blocked by git-secrets: ${commit_output}"
}

test_new_repo_allows_clean_commit() {
  setup_home
  new_repo
  [[ -x .git/hooks/pre-commit ]] || fail "pre-commit hook is not installed"
  try_commit "hello" || fail "clean commit was blocked"
}

test_hooks_match_git_secrets_install() {
  setup_home
  git secrets --install "${tmp}/expected" >/dev/null 2>&1 || fail "git secrets --install failed"
  diff -r "${tmp}/expected/hooks" "${tmp}/.git-templates/git-secrets/hooks" \
    || fail "hooks differ from git secrets --install"
  local hook
  for hook in commit-msg pre-commit prepare-commit-msg; do
    [[ -x "${tmp}/.git-templates/git-secrets/hooks/${hook}" ]] || fail "not executable: ${hook}"
  done
}

main() {
  local tests=("$@")
  if [[ ${#tests[@]} -eq 0 ]]; then
    tests=(
      test_new_repo_blocks_secret_commit
      test_new_repo_allows_clean_commit
      test_hooks_match_git_secrets_install
    )
  fi
  local passed=0 failed=0 name
  for name in "${tests[@]}"; do
    if ("${name}"); then
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
