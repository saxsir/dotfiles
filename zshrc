# ============================================================
# 起動時間プロファイリング（開始）
# ============================================================
# zmodload zsh/zprof

# ============================================================
# Homebrew
# ============================================================
eval "$(/opt/homebrew/bin/brew shellenv)"

# ============================================================
# 環境変数・PATH
# ============================================================
export EDITOR="nvim"
export VISUAL="$EDITOR"
export CLAUDE_PATH="$HOME/.local/bin/claude"

# coreutils
# refs http://qiita.com/catatsuy/items/00ebf78f56960b6d43c2#2-4
if [ -d /opt/homebrew/opt/coreutils/libexec/gnubin ]; then
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
  export MANPATH=/opt/homebrew/opt/coreutils/libexec/gnuman:$MANPATH
else
  export LSCOLORS=gxfxcxdxbxegedabagacad
  alias ls='ls -G'
fi

# go
if [ -d "/usr/local/go/" ]; then
  export PATH=/usr/local/go/bin:$PATH
  export GOPATH=$HOME
  export GOROOT=$(go env GOROOT)
  export PATH=$GOPATH/bin:$PATH
fi

# uv / pip
export PATH="$PATH:$HOME/.local/bin"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# ============================================================
# プラグインマネージャ（zinit）
# ============================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# プラグイン（turboモードで遅延読み込み）
zinit wait lucid for \
  OMZL::git.zsh \
  OMZL::directories.zsh \
  atload'bindkey "^r" peco-select-history; bindkey "^p" peco-src; bindkey "^j" select_worktree' OMZL::key-bindings.zsh \
  OMZP::git \
  atload"_zsh_autosuggest_start" zsh-users/zsh-autosuggestions \
  zsh-users/zsh-completions

# autosuggestのスタイル設定
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=green,bold"

# ============================================================
# プロンプト
# ============================================================
eval "$(starship init zsh)"

# ============================================================
# シェルオプション
# ============================================================
setopt hist_ignore_all_dups

# ============================================================
# エイリアス
# ============================================================
alias vi='vi -u NONE'
alias vim='nvim'
alias -g G='| grep'
alias -g L='| lv'
alias -g V='| vim -'
alias -g C='| pbcopy'
alias matrix="cmatrix -s -u 6"
alias gce='git commit --allow-empty'
alias claude="$CLAUDE_PATH"

# ============================================================
# 関数
# ============================================================

# Wrap aws-vault exec
function avt {
  profile=$1; shift
  aws-vault exec $profile -- aws "$@";
}

# peco: 履歴検索
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

# peco: リポジトリ移動
function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}

# peco x git worktree
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

# ============================================================
# キーバインド
# ============================================================
zle -N peco-select-history
zle -N peco-src
zle -N select_worktree
bindkey '^r' peco-select-history
bindkey '^p' peco-src
bindkey '^j' select_worktree

# ============================================================
# ツール初期化
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

# Kiro
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# ============================================================
# 補完
# ============================================================
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ============================================================
# パス重複除去
# ============================================================
typeset -U path

# ============================================================
# 起動時間プロファイリング（終了）・zcompile
# ============================================================
if type zprof > /dev/null 2>&1; then
  zprof | less
fi

if [ ! -f ~/.zshrc.zwc -o ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi
if [ ! -f ~/.zcompdump.zwc -o ~/.zcompdump -nt ~/.zcompdump.zwc ]; then
  zcompile ~/.zcompdump
fi
