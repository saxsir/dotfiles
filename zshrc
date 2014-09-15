# シェルを起動する度に読み込まれる

#####
# 補完
# /usr/local/share/zsh-completions をfpathに登録(autoload関数が使えるようになる）
fpath=(/usr/local/share/zsh-completions $fpath)

# 補完を有効にする
autoload -Uz compinit
compinit -u

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

source $HOME/.zshrc.mine
