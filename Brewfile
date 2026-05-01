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

# Nerd Font (ターミナル)
cask "font-plemol-jp-nf"
