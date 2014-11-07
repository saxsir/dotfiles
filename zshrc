# シェルを起動する度に読み込まれる

###
# zshのテーマを設定
source $ZSH/oh-my-zsh.sh

#####
# 補完
# /usr/local/share/zsh-completions をfpathに登録(autoload関数が使えるようになる）
fpath=(~/.zsh/zsh-completions/src(N-/) $fpath)

# 補完を有効にする
autoload -Uz compinit
compinit -u

#####
# プロンプト
export RPROMPT="${HOST}"

#####
# Command history configuration
# =の前後に空白入れたらダメ
HISTFILE=${HOME}/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt hist_ignore_dups # ignore duplication command history list
setopt share_history # share command history data

#####
# zshで特定のコマンドをヒストリに追加しない条件を柔軟に設定する - mollifier delta blog
# http://mollifier.hatenablog.com/entry/20090728/p1
# 3文字以下 or コマンド名がmかmanのいずれかだったらヒストリに追加しない
zshaddhistory() {
    local line=${1%%$'\n'}
    local cmd=${line%% *}

    # 以下の条件をすべて満たすものだけをヒストリに追加する
    [[ ${#line} -ge 4
        && ${cmd} != (m|man)
    ]]
}

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# beep を無効にする
setopt no_beep

# ディレクトリ名だけでcdする
setopt auto_cd

#########
# alias
# ls
alias l='ls'
alias la='ls -la'
alias ll='ls -lH'

# git
alias g='git'
alias gst='git status'
alias gl='git log'
alias ga='git add'
alias gc='git commit'
alias gb='git branch'
alias gco='git checkout'

# gem
alias be="bundle exec"

#########
# global alias
alias -g G='| grep'
alias -g L='| less'

source $HOME/.zshrc.mine
