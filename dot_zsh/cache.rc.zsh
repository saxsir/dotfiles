# 外部コマンドの init 出力をキャッシュする仕組み
# loader (dot_zshrc) が最初に source する

# devbox / starship 等の `eval "$(cmd init)"` は静的なシェルコードを吐くだけだが、
# 毎回 subprocess を起動するぶんが起動時間に効く (devbox completion で 160ms)。
# 生成元バイナリより新しいキャッシュがあれば再実行せず source する。
ZSH_INIT_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-init"

# cached_source <key> <command> [args...]
#
# key はキャッシュファイル名であると同時に、更新を監視するコマンド名でもある。
# `git wt --init zsh` のように起動コマンド ($1) と実体が別なケースがあるため、
# 監視対象を $1 ではなく key から引く (key=git-wt なら git-wt の mtime を見る)。
function cached_source() {
  local key="$1"
  shift
  local cache="${ZSH_INIT_CACHE_DIR}/${key}.zsh"
  local watch="${commands[$key]:-${commands[$1]:-$1}}"

  if [[ ! -f "${cache}" || "${watch}" -nt "${cache}" ]]; then
    [[ -d "${ZSH_INIT_CACHE_DIR}" ]] || mkdir -p "${ZSH_INIT_CACHE_DIR}"
    if "$@" > "${cache}.$$" 2> /dev/null; then
      mv -f "${cache}.$$" "${cache}"
    else
      # 生成に失敗したらキャッシュを使わず素の eval に落とす。
      # 黙って何も読まないと、プロンプトや補完が無い shell の原因が追えなくなる
      rm -f "${cache}.$$"
      print -u2 "cached_source: ${key} の生成に失敗した。キャッシュなしで実行する"
      eval "$("$@")"
      return
    fi
  fi

  # 壊れたキャッシュを抱えたまま毎起動同じエラーを出さないよう、
  # source に失敗したら捨てて生成し直す
  if ! source "${cache}"; then
    print -u2 "cached_source: ${cache} が壊れている。再生成する"
    rm -f "${cache}"
    eval "$("$@")"
  fi
}

# ツールを更新してもバイナリの mtime が変わらないケース用の手動リセット
function zsh-init-cache-clear() {
  rm -f "${ZSH_INIT_CACHE_DIR}"/*.zsh(N)
  echo "cleared ${ZSH_INIT_CACHE_DIR} (exec zsh で再生成)"
}
