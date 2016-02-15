export EDITOR=vim

# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="amuse"
DISABLE_UPDATE_PROMPT=true
plugins+=(zsh-completions git docker)
autoload -U compinit && compinit -u
source $ZSH/oh-my-zsh.sh

# prompt
RPROMPT='${HOST}'

# aliases
alias -g G='| grep'
alias -g L='| lv'

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

# hub
eval "$(hub alias -s)"

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
source ~/.zshrc.local

# 重複してるパスを除去
typeset -U path

# 次回からはコンパイルしたものを使う
if [ ! -f ~/.zshrc.zwc -o ~/.zshrc -nt ~/.zshrc.zwc ]; then
   zcompile ~/.zshrc
fi

# 時間計測
if (which zprof > /dev/null); then
  zprof | less
fi
