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
# if type zprof > /dev/null 2>&1; then
#   zprof | less
# fi

# compile済みファイルがない or zshrcの方が修正されていたらコンパイルする
if [ ! -f ~/.zshrc.zwc -o ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi
