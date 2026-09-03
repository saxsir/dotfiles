# 外部ツール統合 (プラグインマネージャ / プロンプト / 補完 / フック)

# ============================================================
# zinit (プラグインマネージャ)
# ============================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# プラグイン (turbo モードで遅延読み込み)
zinit wait lucid for \
  OMZL::git.zsh \
  OMZL::directories.zsh \
  atload'bindkey "^r" peco-select-history; bindkey "^p" peco-src; bindkey "^j" select_worktree' OMZL::key-bindings.zsh \
  OMZP::git \
  atload"_zsh_autosuggest_start" zsh-users/zsh-autosuggestions \
  zsh-users/zsh-completions

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=green,bold"

# ============================================================
# 補完 (compinit)
# 以降の devbox/mise/gcloud/bun 等の補完登録は compdef を呼ぶため、
# それらより前に compinit を済ませておく必要がある。
# zinit プラグインは turbo (wait lucid) 読み込みで初回プロンプト後に
# 展開されるため、ここで compinit しても影響しない。
# ============================================================
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ============================================================
# starship (プロンプト)
# ============================================================
eval "$(starship init zsh)"

# ============================================================
# 関数 (peco / ghq / fzf / aws-vault)
# ============================================================

# aws-vault exec の薄ラッパ
function avt {
  profile=$1; shift
  aws-vault exec $profile -- aws "$@";
}

# peco x history
function peco-select-history() {
  local tac
  if which tac > /dev/null; then
    tac="tac"
  else
    tac="tail -r"
  fi
  BUFFER=$(fc -l -n 1 | eval $tac | peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}

# peco x ghq (リポジトリ移動)
function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}

# fzf x git worktree
function select_worktree() {
  local worktrees
  worktrees=$(git worktree list --porcelain | awk '/worktree / {print $2}')
  if [[ -z "$worktrees" ]]; then
    echo "No worktrees found."
    return 1
  fi
  local selected
  selected=$(echo "$worktrees" | fzf)
  if [[ -n "$selected" ]]; then
    BUFFER="cd ${selected}"
    zle accept-line
  fi
  zle clear-screen
}

# キーバインド (peco/fzf 関数を ZLE に登録)
zle -N peco-select-history
zle -N peco-src
zle -N select_worktree
bindkey '^r' peco-select-history
bindkey '^p' peco-src
bindkey '^j' select_worktree

# ============================================================
# その他ツール初期化
# ============================================================

# direnv
if which direnv > /dev/null; then eval "$(direnv hook zsh)"; fi

# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then source "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then source "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# mise
eval "$(mise activate zsh)"

# git-wt
if command -v git-wt &> /dev/null; then
  eval "$(git wt --init zsh)"
fi

# bun completion
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# devbox completion (devbox 本体は macbook-provisioning の Brewfile のコメント参照: 別途 curl install)
if command -v devbox >/dev/null 2>&1; then
  eval "$(devbox completion zsh)"
fi

# yazi: 終了時に cd 先を引き継ぐラッパ (公式推奨)
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}

# ============================================================
# cmux: workspace の repo 単位自動グループ化
# ============================================================
# cmux 内の shell で ghq 管理 repo (~/src/<host>/<owner>/<repo>) に cd したら、
# 現在の workspace を「<owner頭文字>/<repo>」名の sidebar グループへ移動する。
# グループが無ければ repo root を anchor cwd として自動作成する。
# worktree (repo/.wt/<branch>) も前方一致で本体 repo のグループに入る。
function _cmux_auto_group() {
  [[ -n "${CMUX_WORKSPACE_ID}" ]] || return 0
  # socket が無い (cmux 停止中など) 間はキャッシュせず戻り、次の cd で再試行する
  [[ -S "${CMUX_SOCKET_PATH:-}" ]] || return 0
  command -v cmux > /dev/null || return 0
  command -v jq > /dev/null || return 0

  # ghq root は初回の呼び出しでのみ解決する (shell 起動時の subprocess 起動を避ける)
  if [[ -z "${_cmux_auto_group_src_root:-}" ]]; then
    _cmux_auto_group_src_root="$(ghq root 2> /dev/null)"
    _cmux_auto_group_src_root="${_cmux_auto_group_src_root:-${HOME}/src}"
  fi
  local src_root="${_cmux_auto_group_src_root}"

  # symlink 経由の cd も実パスで判定する
  local pwd_real="${PWD:A}"
  local rel="${pwd_real#"${src_root}"/}"
  [[ "${rel}" != "${pwd_real}" ]] || return 0
  local -a parts=("${(@s:/:)rel}")
  # gist.github.com 等 owner 階層が無いパスは対象外
  (( ${#parts} >= 3 )) || return 0
  local host="${parts[1]}" owner="${parts[2]}" repo="${parts[3]}"
  local repo_root="${src_root}/${host}/${owner}/${repo}"
  # ghq root 配下でも repo でないディレクトリは対象外
  [[ -e "${repo_root}/.git" ]] || return 0
  local group_name="${owner[1,1]}/${repo}"

  # 同一 repo 内の cd では何もしない
  [[ "${repo_root}" != "${_cmux_auto_group_last_root:-}" ]] || return 0
  _cmux_auto_group_last_root="${repo_root}"

  # cd をブロックしないようバックグラウンドで cmux API を叩く。
  # 複数 shell の同時起動でグループが重複作成されないよう flock で直列化し、
  # ロック取得後に状態を読み直してから add / create を決める
  (
    zmodload zsh/system 2> /dev/null || return 0
    local lockfile="${TMPDIR:-/tmp}/cmux-auto-group.lock"
    : >> "${lockfile}"
    zsystem flock -t 5 "${lockfile}" 2> /dev/null || return 0

    local groups_json decision
    groups_json="$(command cmux workspace group list --json --id-format both 2> /dev/null)" || return 0
    decision="$(jq -r --arg ws "${CMUX_WORKSPACE_ID}" --arg name "${group_name}" '
      if any(.groups[]?; .anchor_workspace_id == $ws) then "anchor"
      else (first(.groups[]? | select(.name == $name)) // null) as $g
        | if $g == null then "missing"
          elif ($g.member_workspace_ids | index($ws)) != null then "member"
          else $g.id
          end
      end' <<< "${groups_json}" 2> /dev/null)" || return 0

    case "${decision}" in
      # anchor: 自分がどこかのグループヘッダーのときは触らない (移動はグループ解散を招く)
      anchor|member|"") ;;
      missing)
        command cmux workspace group create --name "${group_name}" --cwd "${repo_root}" \
          --from "${CMUX_WORKSPACE_ID}" > /dev/null 2>&1
        ;;
      *)
        command cmux workspace group add --group "${decision}" --workspace "${CMUX_WORKSPACE_ID}" > /dev/null 2>&1
        ;;
    esac
  ) &!
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _cmux_auto_group
# repo cwd で直接開かれた新規 workspace も起動時に整理する。
# interactive 限定: `zsh -c 'source ~/.zshrc'` 等の検証コマンドが sidebar を書き換えないように
if [[ -o interactive ]]; then
  _cmux_auto_group
fi
