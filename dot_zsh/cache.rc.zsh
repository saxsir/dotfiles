# 外部コマンドの init 出力をキャッシュする仕組み
# loader (dot_zshrc) が最初に source する

# devbox / starship / mise 等の `eval "$(cmd init)"` は静的なシェルコードを吐くだけだが、
# 毎回 subprocess を起動するぶん起動時間に効く (devbox completion で 160ms)。
# 生成元バイナリより新しいキャッシュがあれば再実行せず source する。
ZSH_INIT_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-init"

# cached_source <key> <command> [args...]
function cached_source() {
  local key="$1"
  shift
  local cache="${ZSH_INIT_CACHE_DIR}/${key}.zsh"
  local bin_path="${commands[$1]:-$1}"

  if [[ ! -s "${cache}" || "${bin_path}" -nt "${cache}" ]]; then
    [[ -d "${ZSH_INIT_CACHE_DIR}" ]] || mkdir -p "${ZSH_INIT_CACHE_DIR}"
    if ! "$@" > "${cache}.$$" 2> /dev/null; then
      rm -f "${cache}.$$"
      return 1
    fi
    mv -f "${cache}.$$" "${cache}"
  fi

  source "${cache}"
}

# ツールを更新してもバイナリの mtime が変わらないケース用の手動リセット
function zsh-init-cache-clear() {
  rm -rf "${ZSH_INIT_CACHE_DIR}"
  echo "cleared ${ZSH_INIT_CACHE_DIR} (exec zsh で再生成)"
}
