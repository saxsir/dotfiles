#!/usr/bin/env bash
# ~/.claude-vanilla の会話履歴、入力履歴 (history.jsonl)、auto-memory、NOTES.md を ~/.claude へ移す。
# vanilla を使っていたマシンごとに 1 回実行する。Claude Code を全部終了してから実行すること。
#
# - コピーするだけで、~/.claude-vanilla は消さない
# - 同じ名前で中身が違うファイルは、上書きする前に退避先へ写す
# - memory が両方にあるときは vanilla 側を採り、main 側の memory ディレクトリを退避する
# - history.jsonl は両方の行をつなげ、重複行を除いて timestamp 順に並べ直す。元のファイルは退避する
# - 終わったら ~/.claude/.vanilla-migrated を置き、以降の実行は何もしない。~/.claude-vanilla が無いときも何もしない
#
# 使い方: bash misc/bin/migrate-claude-vanilla.sh [--dry-run]
# 移す元と先は環境変数 VANILLA_DIR / MAIN_DIR で変えられる。SKIP_RUNNING_CHECK=1 で Claude Code 稼働中の確認を外す (どれもテスト用)
set -euo pipefail

vanilla_dir="${VANILLA_DIR:-${HOME}/.claude-vanilla}"
main_dir="${MAIN_DIR:-${HOME}/.claude}"
backup_dir="${main_dir}/vanilla-migration-backup"
# 移行後に ~/.claude 側で育った memory などを、古い vanilla 版で戻さないための印
done_marker="${main_dir}/.vanilla-migrated"
merged=""
trap 'rm -f "${merged}"' EXIT
dry_run=0

case "${1:-}" in
  --dry-run) dry_run=1 ;;
  "") ;;
  *)
    echo "usage: $0 [--dry-run]" >&2
    exit 2
    ;;
esac

log() {
  printf '%s\n' "$*"
}

run() {
  if [[ "${dry_run}" -eq 1 ]]; then
    log "  (dry-run) $*"
  else
    "$@"
  fi
}

# 退避先は実行時刻に依らない固定のパスにする。既にあれば (= 前回退避済み) 上書きせずに止める
backup() {
  local src="$1" rel="$2"
  local dest="${backup_dir}/${rel}"
  if [[ -e "${dest}" ]]; then
    echo "error: 退避先が既にある: ${dest}" >&2
    echo "       前回の退避を確かめてから、不要なら消して再実行する" >&2
    exit 1
  fi
  log "backup: ${src} -> ${dest}"
  run mkdir -p "$(dirname "${dest}")"
  run cp -Rp "${src}" "${dest}"
}

# 1 ファイルを写す。同じ中身なら何もしない、違えば退避してから上書きする
copy_file() {
  local src="$1" rel="$2"
  local dest="${main_dir}/${rel}"
  if [[ -e "${dest}" ]]; then
    if cmp -s "${src}" "${dest}"; then
      return 0
    fi
    backup "${dest}" "${rel}"
  fi
  log "copy: ${rel}"
  run mkdir -p "$(dirname "${dest}")"
  run cp -p "${src}" "${dest}"
}

migrate_sessions() {
  local rel
  # memory/ を除く projects 配下のファイル (<uuid>.jsonl と <uuid>/ の中身)
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    copy_file "${vanilla_dir}/projects/${rel}" "projects/${rel}"
  done < <(cd "${vanilla_dir}/projects" && find . -path './*/memory' ! -path './*/*/*' -prune -o -type f -print0)
}

migrate_memory() {
  local src name dest
  for src in "${vanilla_dir}"/projects/*/memory; do
    [[ -d "${src}" ]] || continue
    name="$(basename "$(dirname "${src}")")"
    dest="${main_dir}/projects/${name}/memory"
    if [[ -d "${dest}" ]]; then
      if diff -rq "${src}" "${dest}" > /dev/null 2>&1; then
        continue
      fi
      backup "${dest}" "projects/${name}/memory"
      log "replace memory: ${name}"
      run rm -rf "${dest}"
    else
      log "copy memory: ${name}"
    fi
    run mkdir -p "$(dirname "${dest}")"
    run cp -Rp "${src}" "${dest}"
  done
}

migrate_history() {
  local src="${vanilla_dir}/history.jsonl" dest="${main_dir}/history.jsonl"
  [[ -f "${src}" ]] || return 0
  if [[ ! -e "${dest}" ]]; then
    copy_file "${src}" "history.jsonl"
    return 0
  fi
  merged="$(mktemp "${main_dir}/history.jsonl.XXXXXX")"
  # 行はそのまま残し、timestamp だけを取り出して安定ソートする。重複行は先に除く。
  # cat でつなぐと末尾に改行の無いファイルの最終行が次の行と繋がるので、awk に 2 ファイルとも渡す
  awk 'NF && !seen[$0]++' "${dest}" "${src}" \
    | jq -R -r '((fromjson? | .timestamp) // 0 | tostring) + "\t" + .' \
    | LC_ALL=C sort -s -t $'\t' -k1,1n \
    | cut -f2- > "${merged}"
  if cmp -s "${merged}" "${dest}"; then
    rm -f "${merged}"
    return 0
  fi
  backup "${dest}" "history.jsonl"
  log "merge: history.jsonl ($(wc -l < "${dest}") + $(wc -l < "${src}") -> $(wc -l < "${merged}") lines)"
  if [[ "${dry_run}" -eq 1 ]]; then
    rm -f "${merged}"
  else
    mv "${merged}" "${dest}"
  fi
}

main() {
  if [[ ! -d "${vanilla_dir}" ]]; then
    log "${vanilla_dir} が無いので何もしない"
    return 0
  fi
  if [[ -e "${done_marker}" ]]; then
    log "移行済み (${done_marker} がある) なので何もしない"
    return 0
  fi
  if [[ ! -d "${main_dir}" ]]; then
    echo "error: ${main_dir} が無い" >&2
    exit 1
  fi
  command -v jq > /dev/null || {
    echo "error: jq が要る" >&2
    exit 1
  }
  if [[ "${dry_run}" -eq 0 && -z "${SKIP_RUNNING_CHECK:-}" ]] && pgrep -x claude > /dev/null; then
    echo "error: Claude Code が動いている。history.jsonl の書き込みが消えないよう、全部終了してから実行する" >&2
    exit 1
  fi
  if [[ -d "${vanilla_dir}/projects" ]]; then
    migrate_sessions
    migrate_memory
  fi
  migrate_history
  if [[ -f "${vanilla_dir}/NOTES.md" ]]; then
    copy_file "${vanilla_dir}/NOTES.md" "NOTES.md"
  fi
  run touch "${done_marker}"
  log "done"
}

main
