# コメント外すと起動時間を計測する
# zmodload zsh/zprof

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

# pyenv
PYENV_ZSH_FILE="$HOME/.pyenv-zsh"
if [ -f "$PYENV_ZSH_FILE" ]; then
  source $PYENV_ZSH_FILE
else
  if which pyenv > /dev/null; then
    echo "$(pyenv init - --no-rehash)" > $PYENV_ZSH_FILE
    source $PYENV_ZSH_FILE
  fi
fi

# pyenv-virtualenv
PYENV_VIRTUALENV_ZSH_FILE="$HOME/.pyenv-virtualenv-zsh"
if [ -f "$PYENV_VIRTUALENV_ZSH_FILE" ]; then
  source $PYENV_VIRTUALENV_ZSH_FILE
else
  if which pyenv-virtualenv > /dev/null; then
    echo "$(pyenv virtualenv-init -)" > $PYENV_VIRTUALENV_ZSH_FILE
    source $PYENV_VIRTUALENV_ZSH_FILE
  fi
fi

# direnv
if which direnv > /dev/null; then eval "$(direnv hook zsh)"; fi
