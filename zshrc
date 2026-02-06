# 起動時間のプロファイリングしたい時はコメントアウトを外す
# zmodload zsh/zprof

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# coreutils
# refs http://qiita.com/catatsuy/items/00ebf78f56960b6d43c2#2-4
if [ -d /opt/homebrew/opt/coreutils/libexec/gnubin ]; then
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
  export MANPATH=/opt/homebrew/opt/coreutils/libexec/gnuman:$MANPATH
else
  export LSCOLORS=gxfxcxdxbxegedabagacad
  alias ls='ls -G'
fi

# === zinit ===
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

# === Starship ===
eval "$(starship init zsh)"

# common aliases
alias vi='vi -u NONE'
alias vim='nvim'
alias -g G='| grep'
alias -g L='| lv'
alias -g V='| vim -'
alias -g C='| pbcopy'
alias matrix="cmatrix -s -u 6"
alias gce='git commit --allow-empty'
export CLAUDE_PATH="$HOME/.local/bin/claude"
alias claude="$CLAUDE_PATH"
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Wrap aws-vault exec
function avt {
  profile=$1; shift
  aws-vault exec $profile -- aws "$@";
}

# peco
setopt hist_ignore_all_dups
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
zle -N peco-select-history
bindkey '^r' peco-select-history

function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^p' peco-src

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
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N select_worktree
bindkey '^j' select_worktree

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# direnv
if which direnv > /dev/null; then eval "$(direnv hook zsh)"; fi

# go
if [ -d "/usr/local/go/" ]; then
  export PATH=/usr/local/go/bin:$PATH
  export GOPATH=$HOME
  export GOROOT=$(go env GOROOT)
  export PATH=$GOPATH/bin:$PATH
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then source "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then source "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# uv
export PATH="$PATH:$HOME/.local/bin"

# mise
eval "$(mise activate zsh)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# git-wt
if command -v git-wt &> /dev/null; then
  eval "$(git wt --init zsh)"
fi

# 補完の初期化を遅延させる
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# 重複してるパスを除去
typeset -U path

# 起動時間のプロファイリング
if type zprof > /dev/null 2>&1; then
  zprof | less
fi

# compile済みファイルがない or zshrcの方が修正されていたらコンパイルする
if [ ! -f ~/.zshrc.zwc -o ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi
if [ ! -f ~/.zcompdump.zwc -o ~/.zcompdump -nt ~/.zcompdump.zwc ]; then
  zcompile ~/.zcompdump
fi
