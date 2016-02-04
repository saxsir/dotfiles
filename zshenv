# コメント外すと起動時間を計測する
# zmodload zsh/zprof && zpro

export EDITOR=vim

# rbenv
RBENV_ZSH_FILE="$HOME/.rbenv-zsh"
if [ -f "$RBENV_ZSH_FILE" ]; then
  source $RBENV_ZSH_FILE
else
  if which rbenv > /dev/null; then
    echo "$(rbenv init - --no-rehash)" > $RBENV_ZSH_FILE
    source $RBENV_ZSH_FILE
  fi
fi
