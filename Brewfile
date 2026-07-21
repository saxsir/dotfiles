# dotfiles の動作に必要な最小セット。
# 各自の環境に応じて追加する場合は `brew bundle add <formula>` で書き込める。

# chezmoi 本体とプロンプト
brew "chezmoi"
brew "starship"

# pre-commit (secretlint hook の実行に必要)
brew "pre-commit"

# secretlint を bunx 経由で動かすための Bun
brew "oven-sh/bun/bun"

# 他ツール (npx / mise 経由でない system node を触るもの) が使う可能性のため残す
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

# nvim mini.pick の grep_live (<Leader>fg) が優先ソースとして使う
brew "ripgrep"

# ファイルマネージャ
brew "yazi"

# CLAUDE.md rules で必須指定: gh / jq / git-secrets / aws-vault, claude-vm エイリアスで lima
brew "gh"
brew "jq"
brew "git-secrets"
brew "lima"
brew "aws-vault"

# aws-vault が wrap する本体 CLI (dot_zsh/tool.rc.zsh の avt alias で使用)
brew "awscli"

# dot_gitconfig.tmpl が [filter "lfs"] required = true で LFS を要求している
brew "git-lfs"

# git worktree 運用の補助 (git wt <branch> で作成/切り替え)
brew "k1LoW/tap/git-wt"

# crit skill (apm.yml の tomasz-tomczyk/crit) が呼び出す CLI 本体
brew "crit"

# ターミナルフォント (~/.config/ghostty/config で Moralerspace Neon JPDOC を指定)
# Moralerspace = Monaspace + IBM Plex Sans JP の等幅派生
# -jpdoc: 「」、。等の Unicode 全角記号を JP 側 (IBM Plex Sans JP) で描画
cask "font-moralerspace-jpdoc"
# Moralerspace の JPDOC が拾わない ①②③ (Enclosed Alphanumerics) を全角描画するため。
# Moralerspace 本体と同じ IBM Plex Sans JP なので字形が揃う (config の font-codepoint-map で使用)
cask "font-ibm-plex-sans-jp"
