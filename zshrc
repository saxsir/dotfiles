#####
# 補完
# /usr/local/share/zsh-completions をfpathに登録(autoload関数が使えるようになる）
fpath=(/usr/local/share/zsh-completions $fpath)

# 補完を有効にする
autoload -Uz compinit
compinit -u
