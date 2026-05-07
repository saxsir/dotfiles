# 環境変数と PATH 追加
# (ツール起動 / 補完登録は tool.rc.zsh)

# Editor
export EDITOR="nvim"
export VISUAL="$EDITOR"
export CLAUDE_PATH="$HOME/.local/bin/claude"

# go
if [ -d "/usr/local/go/" ]; then
  export PATH=/usr/local/go/bin:$PATH
  export GOPATH=$HOME
  export GOROOT=$(go env GOROOT)
  export PATH=$GOPATH/bin:$PATH
fi

# uv / pip 等のユーザーローカル bin
export PATH="$PATH:$HOME/.local/bin"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Snowflake CLI (macOS app bundle 内)
if [ -d "$HOME/Applications/SnowflakeCLI.app/Contents/MacOS" ]; then
  export PATH="$HOME/Applications/SnowflakeCLI.app/Contents/MacOS:$PATH"
fi
