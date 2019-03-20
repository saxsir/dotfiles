# common aliases
alias vi='vi -u NONE'
alias -g G='| grep'
alias -g L='| lv'

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

# compile済みファイルがない or zshrcの方が修正されていたらコンパイルする
if [ ! -f ~/.zshrc.zwc -o ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
