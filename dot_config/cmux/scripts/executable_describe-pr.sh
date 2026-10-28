#!/usr/bin/env bash
# cmux workspace の description を PR タイトルにする。sidebar (work-board) の
# 1 行目に「何の作業か」を出すため。
#
# Usage:
#   describe-pr.sh              # $CMUX_WORKSPACE_ID に、cwd の branch の PR タイトルを設定
#   describe-pr.sh --url <PR URL>  # cwd の branch でなく、指定 PR のタイトルを設定
#   describe-pr.sh --all        # PR を持ち description が空の全 workspace に設定 (backfill)
#   describe-pr.sh [--all] --dry-run   # 設定せず "<workspace ref>\t<description>" を表示
#
# description はタイトルだけにする。PR 番号と status は sidebar の 2 行目に
# 出るので、description に入れると重複する。
#
# Why-not: `--all` は `cmux workspace list --json` に PR 情報が無い (0.65.2 で確認)
# ため、workspace ごとに `cmux sidebar-state` の `pr=` 行から URL を取る。
#
# どの前提が欠けても何もせず exit 0 (hook から呼ばれても Claude を妨げない)。
set -uo pipefail

all=0
dry_run=0
pr_ref=""
while (($#)); do
  case "$1" in
    --all) all=1 ;;
    --dry-run) dry_run=1 ;;
    --url)
      pr_ref="${2:-}"
      shift
      ;;
  esac
  shift
done

for cmd in cmux gh jq; do
  command -v "${cmd}" >/dev/null 2>&1 || exit 0
done

set_description() {
  local ref="$1" title="$2"
  [[ -z "${title}" ]] && return 0
  if ((dry_run)); then
    printf '%s\t%s\n' "${ref}" "${title}"
    return 0
  fi
  cmux workspace-action --workspace "${ref}" --action set-description \
    --description "${title}" >/dev/null 2>&1 || true
}

if ((all)); then
  while IFS=$'\t' read -r ref; do
    [[ -z "${ref}" ]] && continue
    url=$(cmux sidebar-state --workspace "${ref}" 2>/dev/null |
      sed -n 's/^pr=//p' | grep -Eo 'https?://[^[:space:]]+' | head -n 1) || true
    [[ -z "${url}" ]] && continue
    title=$(gh pr view "${url}" --json title --jq .title 2>/dev/null) || continue
    set_description "${ref}" "${title}"
  done < <(cmux workspace list --json 2>/dev/null |
    jq -r '.workspaces[]? | select((.description // "") == "") | .ref')
  exit 0
fi

[[ -z "${CMUX_WORKSPACE_ID:-}" ]] && exit 0
pr_args=()
[[ -n "${pr_ref}" ]] && pr_args=("${pr_ref}")
pr_json=$(gh pr view ${pr_args[@]+"${pr_args[@]}"} --json title,url 2>/dev/null) || exit 0
title=$(printf '%s' "${pr_json}" | jq -r '.title // empty')
url=$(printf '%s' "${pr_json}" | jq -r '.url // empty')
set_description "${CMUX_WORKSPACE_ID}" "${title}"
# Why: cmux の PR 自動検出は workspace の cwd の branch を見る。dude の作業は
# worktree で進み workspace はリポジトリ直下 (default branch) に居るので、
# 明示的に紐づけないと sidebar に PR も REVIEW lane も出ない。
if [[ -n "${url}" ]] && ((!dry_run)); then
  cmux pr "${url}" --workspace "${CMUX_WORKSPACE_ID}" >/dev/null 2>&1 || true
fi
exit 0
