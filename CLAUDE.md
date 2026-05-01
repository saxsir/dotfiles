# CLAUDE.md

<!-- このファイルは継続的に改善されます。Claudeとの作業で得た知見を随時追加してください -->

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository that manages development environment configurations, primarily for macOS (Darwin) and Linux systems. The repository is managed by [chezmoi](https://www.chezmoi.io/); the Makefile is a thin wrapper that installs deps (Homebrew formulas) and runs `chezmoi apply`.

## Essential Commands

### Setup and Installation
```bash
# Complete setup (install deps + chezmoi apply)
make

# Individual targets
make deps      # brew で chezmoi/starship/font 等を準備
make apply     # chezmoi apply で ~/ にファイル配置 (初回は init で name/email プロンプト)
make diff      # 適用前に差分確認
```

### Testing and Validation
```bash
# IMPORTANT: Always test configuration changes before committing
# Test zsh configuration syntax
zsh -n ~/.zshrc

# Reload and verify zsh configuration
zsh -c 'source ~/.zshrc && echo "OK"'

# Dry-run chezmoi apply
chezmoi diff

# Test zsh startup performance (built-in profiling)
# Set ENABLE_STARTUP_PROFILING=1 before starting new shell
ENABLE_STARTUP_PROFILING=1 zsh -i -c exit
```

## Architecture and Structure

### Configuration Management Pattern
- **chezmoi-based**: リポジトリルートが chezmoi の source root。`chezmoi apply` でホームディレクトリに実ファイルとして配置される
- **Local overrides**: `zshrc.local` は `create_dot_zshrc.local` 由来。既存ファイルは上書きされない (machine-specific 設定保護)
- **gitconfig template**: `dot_gitconfig.tmpl` に `{{ .name }}` / `{{ .email }}` を埋めており、初回 `chezmoi init` で対話的に入力 → `~/.config/chezmoi/chezmoi.toml` に保存
- **chezmoi 管理外**: `Makefile`, `README.md`, `LICENSE`, `lima/`, `misc/` 等のリポメタは `.chezmoiignore` で適用対象から除外

### Key Components

1. **Shell Environment (Zsh)**
   - Main config: `dot_zshrc` - Core configuration with zinit (プラグインマネージャ), peco/ghq integration
   - Performance optimizations: Lazy loading for heavy tools (nvm, pyenv), zcompile usage

2. **Development Tools Integration**
   - Git: Extensive aliases in `gitconfig`, git-secrets for AWS credential protection
   - Package managers: Homebrew (macOS), mise (version manager for multiple languages)
   - Terminal multiplexer: tmux with vim-like keybindings

3. **Editor Configurations**
   - NeoVim: Basic configuration with mini.deps support
   - IdeaVim: Inherits vimrc with additional IntelliJ-specific settings

4. **Lima VM (Development Containers)**
   - Claude Code実行用VM: `lima/claude-dev.yaml` - Ubuntu 24.04 ARM64, Apple Virtualization.framework
   - ホストの`~/src`を読み書き可能でマウント、ホームは読み取り専用

### NeoVim Keymap Reference

#### 基本操作 (`config/keymaps.lua`)
| キー | 説明 |
|------|------|
| `<C-c><C-e>e` | vimrc編集 |
| `<C-c><C-e>s` | vimrc再読込 |
| `jj` | ESC (挿入モード) |
| `;` | `:` |
| `<C-h/j/k/l>` | ウィンドウ移動 |
| `%%` | カレントディレクトリ展開 (コマンドモード) |
| `<Esc>` | 検索ハイライト解除 |
| `<` / `>` | インデント調整 (選択維持) |
| `<Leader>cp` | ファイルパスをコピー (Visualモード: 行番号付き) |

#### ファイル操作 (`plugins/init.lua`, `plugins/picker.lua`)
| キー | 説明 |
|------|------|
| `-` | mini.files を開く |
| `<Leader>ff` | ファイル検索 |
| `<Leader>fg` | grep検索 |
| `<Leader>fb` | バッファ一覧 |
| `<Leader>fh` | ヘルプ検索 |
| `<Leader>fr` | 最近開いたファイル |

#### Git操作 (`plugins/git.lua`)
| キー | 説明 |
|------|------|
| `<Leader>gs` | Git status |
| `<Leader>gc` | Git commit |
| `<Leader>gp` | Git push |
| `<Leader>gl` | Git log |
| `<Leader>gd` | Git diff |
| `<Leader>gb` | Git blame |
| `<Leader>gB` | カーソル行のblame (virtual text) |

**Blameバッファ内:**
| キー | 説明 |
|------|------|
| `<CR>` | コミット詳細を表示 |
| `gP` | 該当コミットのPRをブラウザで開く |

#### LSP (`plugins/lsp.lua`)
| キー | 説明 |
|------|------|
| `K` | ホバー (ドキュメント表示) |
| `gd` | 定義へジャンプ |
| `gr` | 参照一覧 |
| `gi` | 実装へジャンプ |
| `<Leader>rn` | リネーム |
| `<Leader>ca` | コードアクション |
| `<Leader>f` | フォーマット |
| `[d` / `]d` | 前/次の診断へジャンプ |
| `<Leader>ss` | ドキュメントシンボル |
| `<Leader>ws` | ワークスペースシンボル |

#### カスタムコマンド (`config/commands.lua`)
| コマンド | 説明 |
|----------|------|
| `:DailyLog` | 今日の日報ファイルを開く |
| `:JunkfileOpen` | タイムスタンプ付きメモファイル作成 |
| `:GHBrowse` | 現在行をGitHubで開く |

### Important Patterns
- **Lazy loading**: Heavy tools are loaded on-demand to improve shell startup time
- **ghq + peco**: Repository management and navigation system (repos in `~/src`)
- **zinit**: zsh プラグインマネージャ。`dot_zshrc` 内で自己 clone する

## Code Style Guidelines

### Shell Scripts (Zsh/Bash)
- Use 2-space indentation
- Variable naming: lowercase with underscores (e.g., `my_variable`)
- IMPORTANT: Quote all variable expansions: `"${variable}"` not `$variable`
- Function naming: lowercase with underscores
- Always include error handling for critical operations

### Configuration Files
- Keep modifications organized by concern (aliases, functions, environment setup)
- Document non-obvious configurations with inline comments
- IMPORTANT: Platform-specific code は `dot_zshrc.tmpl` 化して `{{ if eq .chezmoi.os "darwin" }}` 等で分岐する
- Machine-specific settings belong in `~/.zshrc.local` (chezmoi の `create_` prefix で初回のみ作成、上書きされない)

### Git Practices
- YOU MUST test changes in a new shell session before committing
- Commit messages should explain the "why" for configuration changes
- Keep commits focused on a single logical change

## Repository Workflow

### Branch Strategy
- Branch naming: `feat/`, `fix/`, `chore/` prefixes
- IMPORTANT: Create feature branches from `master` branch
- Example: `feat/add-docker-aliases`, `fix/zsh-startup-time`

### Making Changes
1. masterを最新化: `git switch master && git pull origin master`
2. フィーチャーブランチを作成: `git checkout -b <branch-name>` (例: `git checkout -b feat/add-aliases`)
3. Make changes to configuration files
4. Test changes using commands in "Testing and Validation" section
5. Commit with descriptive message
6. Push changes: `git push -u origin <branch-name>`
7. Create pull request for review (if working in team)
8. **IMPORTANT**: After creating a PR (including draft), always open it in browser with `gh pr view --web`
9. After PR is merged and branch is no longer needed, clean up: `git switch master && git pull origin master && git branch -d <branch-name>`

### Deployment
- IMPORTANT: After merging changes, run `make apply` (= `chezmoi apply`) to update files in `~/`
- Reload shell with `source ~/.zshrc` or start a new shell session
- Verify no errors occur during shell initialization

## Critical Notes

1. **Git user info**: 初回 `chezmoi init` で対話的に入力 → `~/.config/chezmoi/chezmoi.toml` に保存。
   `dot_gitconfig.tmpl` がそれを参照して展開する。リポジトリには個人情報は含まれない。

2. **macOS focus**: While Linux is supported, most optimizations and tool integrations are macOS-centric.
   OS 分岐が必要になったら chezmoi template (`{{ if eq .chezmoi.os "darwin" }}`) で書く。

3. **GNU coreutils**: macOS環境にHomebrew経由でGNU coreutilsをインストール済み。
   `date`コマンド等はGNU版を使用しているため、シェルスクリプトやコマンド提案時はGNU構文（例: `date -d`, `date +%s`）を使用すること。

## Known Issues and Warnings

- **Slow startup**: If shell startup is slow, check lazy-loading configuration in `dot_zshrc`
- **Homebrew on Apple Silicon**: Some formulas may require Rosetta 2 or ARM-specific installation
- **tmux key conflicts**: Custom vim-like bindings may conflict with some terminal applications

