# 起動時間のプロファイリングしたい時はコメントアウトを外す
# zmodload zsh/zprof

# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="jbergantine"
plugins+=(
    git
    docker
    zsh-completions
    zsh-autosuggestions
)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=green,bold"
source $ZSH/oh-my-zsh.sh

# 補完
autoload -U compinit
compinit

# common aliases
alias vi='vi -u NONE'
alias -g G='| grep'
alias -g L='| lv'
alias -g V='| vim -'
alias gce='git commit --allow-empty'

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

# 起動時間のプロファイリング
if type zprof > /dev/null 2>&1; then
  zprof | less
fi

# compile済みファイルがない or zshrcの方が修正されていたらコンパイルする
if [ ! -f ~/.zshrc.zwc -o ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi
