# macOS 固有の初期化
# loader (dot_zshrc) で uname == Darwin の時だけ source される

# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# GNU coreutils (date 等の構文を Linux と揃える)
# refs http://qiita.com/catatsuy/items/00ebf78f56960b6d43c2#2-4
if [ -d /opt/homebrew/opt/coreutils/libexec/gnubin ]; then
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
  export MANPATH=/opt/homebrew/opt/coreutils/libexec/gnuman:$MANPATH
else
  export LSCOLORS=gxfxcxdxbxegedabagacad
  alias ls='ls -G'
fi
