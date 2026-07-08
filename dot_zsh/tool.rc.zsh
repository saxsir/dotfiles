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

# devbox completion (devbox 本体は Brewfile のコメント参照: 別途 curl install)
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
