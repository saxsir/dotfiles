# =================
# Zsh configuration, This file
# - is sourced in interactive shells,
# - should contain commands to set up aliases, functions, options, key bindings, etc.
#
# refs http://zsh.sourceforge.net/Intro/intro_3.html
# =================

# enable zsh theme
source $ZSH/oh-my-zsh.sh

# enable zsh completions
plugins+=(zsh-completions)
autoload -U compinit && compinit -u

# プロンプトを上書き
RPROMPT='${HOST}'

# =======
# Aliases
# =======
# global
alias -g G='| grep'
alias -g L='| less'

# curl
function xhr() {
  curl -s -H 'X-Requested-With: XMLHttpRequest' $1 | jq .
}
alias xhr='xhr'
compdef xhr=curl

# git
# - g, gst, gd, gds, gdc, gdt, gp, gc, gc!, gco, gcm, gr, grv, gb, gba, ga, gm,
#   ggpull, ggpush
#
# refs https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/git/git.plugin.zsh
alias g='git'
compdef g=git
alias gst='git status'
compdef _git gst=git-status
alias gd='git diff'
compdef _git gd=git-diff
alias gds='git diff --stat'
compdef _git gds=git-diff
alias gdc='git diff --cached'
compdef _git gdc=git-diff
alias gdt='git difftool'
compdef _git gdt=git-diff
alias gp='git push'
compdef _git gp=git-push
alias gc='git commit -v'
compdef _git gc=git-commit
alias gc!='git commit -v --amend'
compdef _git gc!=git-commit
alias gce='git commit -v --allow-empty'
compdef _git gc=git-commit
alias gco='git checkout'
compdef _git gco=git-checkout
alias gcm='git checkout master'
alias gr='git remote'
compdef _git gr=git-remote
alias grv='git remote -v'
compdef _git grv=git-remote
alias gb='git branch'
compdef _git gb=git-branch
alias gba='git branch -a'
compdef _git gba=git-branch
alias ga='git add'
compdef _git ga=git-add
alias gm='git merge'
compdef _git gm=git-merge
alias ggpull='git pull origin $(current_branch)'
compdef ggpull=git
alias ggpush='git push origin $(current_branch)'
compdef ggpush=git

# =============
# user function
# =============
# Will return the current branch name
# Usage example: git pull origin $(current_branch)
#
# Will return the current branch name
# Usage example: git pull origin $(current_branch)
#
function current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

function current_repository() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo $(git remote -v | cut -d':' -f 2)
}

setopt hist_ignore_all_dups

function peco_select_history() {
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
zle -N peco_select_history
bindkey '^r' peco_select_history

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

# 環境固有の設定を読み込み
source $HOME/.zshrc.mine
