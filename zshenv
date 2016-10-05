# このファイルにはPATHの設定を書く

# コメント外すと起動時間を計測する
# modload zsh/zprof

setopt no_global_rcs

# rbenv
export RBENV_ROOT=/usr/local/var/rbenv
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
export PYENV_ROOT=/usr/local/var/pyenv
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
# PYENV_ZSH_FILE="$HOME/.pyenv-zsh"
# if [ -f "$PYENV_ZSH_FILE" ]; then
#   source $PYENV_ZSH_FILE
# else
#   if which pyenv > /dev/null; then
#     echo "$(pyenv init - --no-rehash)" > $PYENV_ZSH_FILE
#     source $PYENV_ZSH_FILE
#   fi
# fi

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

# nodebrew
if which nodebrew > /dev/null; then
  export PATH=$HOME/.nodebrew/current/bin:$PATH
fi

# direnv
if which direnv > /dev/null; then
  eval "$(direnv hook zsh)"
fi

# go, ghq
export PATH=/usr/local/go/bin:$PATH
export GOPATH=$HOME
export PATH=$GOPATH/bin:$PATH

# elasticsearch
export PATH=~/bin/elasticsearch-2.3.0/bin:$PATH
