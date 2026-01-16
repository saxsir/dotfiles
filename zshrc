# 起動時間のプロファイリングしたい時はコメントアウトを外す
# zmodload zsh/zprof

# $HOME/.zsh/fatima.sh
# export OPENAI_API_BASE=https://fatima.adingo.jp/openai/v1
# export OPENAI_API_KEY=$(jq -r .access_token $HOME/.fatima/auth0_token.json)
# $HOME/.zsh/update_cursor_api_key.sh

# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
plugins+=(
    git
)
ZSH_THEME="jbergantine"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=green,bold"
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_AUTO_TITLE="true"
source $ZSH/oh-my-zsh.sh

# common aliases
alias vi='vi -u NONE'
alias vim='nvim'
alias -g G='| grep'
alias -g L='| lv'
alias -g V='| vim -'
alias gce='git commit --allow-empty'
export CLAUDE_PATH="$HOME/.claude/local/claude"
alias claude="$CLAUDE_PATH"

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
    echo "$selected"
    cd "$selected"
  fi
}
zle -N select_worktree
bindkey '^j' select_worktree

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# mise
eval "$(mise activate zsh)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

alias npm='pnpm'
alias npx='pnpm dlx'
# pnpm end

# OS依存の設定
case ${OSTYPE} in
  darwin*)
    source ~/.zshrc.darwin
    ;;
  linux*)
    source ~/.zshrc.linux
    ;;
esac

# ローカル固有で設定したい何かがあれば
# e.g. commitしたくないトークンとか
source ~/.zshrc.local

# 重複してるパスを除去
typeset -U path

# 補完の初期化を遅延させる
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# 起動時間のプロファイリング
if type zprof > /dev/null 2>&1; then
  zprof | less
fi

# compile済みファイルがない or zshrcの方が修正されていたらコンパイルする
if [ ! -f ~/.zshrc.zwc -o ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi
if [ ! -f ~/.zcompdump.zwc -o ~/.zcompdump -nt ~/.zcompdump.zwc ]; then
  zrecompile ~/.zshrc ~/.zcompdump
fi
