# dotfiles の動作に必要な最小セット。
# 各自の環境に応じて追加する場合は `brew bundle add <formula>` で書き込める。

# chezmoi 本体とプロンプト
brew "chezmoi"
brew "starship"

# pre-commit (secretlint hook の実行に必要)
brew "pre-commit"

# secretlint を npx 経由で動かすための Node
brew "node"

# プロジェクト単位の環境変数 / シェル切り替え
# devbox は Homebrew core に無いため `curl -fsSL https://get.jetify.com/devbox | bash` で別途導入
brew "direnv"

# 言語ランタイム / CLI バージョン管理 (~/.config/mise/config.toml)
brew "mise"

# age (chezmoi の secret 暗号化に使う。age-keygen も同梱)
brew "age"

# zshrc が依存する CLI (peco-select-history / peco-src / select_worktree, alias matrix/L)
brew "peco"
brew "ghq"
brew "fzf"
brew "cmatrix"
brew "lv"

# GNU coreutils (date 等を Linux と揃える前提。~/.zsh/macos.rc.zsh で gnubin を PATH に追加)
brew "coreutils"

# エディタ ($EDITOR / alias vim='nvim')
brew "neovim"

# CLAUDE.md rules で必須指定: gh / jq / git-secrets / aws-vault, claude-vm エイリアスで lima
brew "gh"
brew "jq"
brew "git-secrets"
brew "lima"
brew "aws-vault"

# ターミナルフォント (~/.config/ghostty/config で Monaspace Neon を指定)
cask "font-monaspace"
