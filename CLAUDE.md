# CLAUDE.md

<!-- このファイルは継続的に改善されます。Claudeとの作業で得た知見を随時追加してください -->

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository that manages development environment configurations, primarily for macOS (Darwin) and Linux systems. The repository uses a Makefile-based setup system to create symlinks from configuration files to the user's home directory.

## Essential Commands

### Setup and Installation
```bash
# Complete setup (install dependencies and create symlinks)
make

# Individual targets
make deps      # Install dependencies (oh-my-zsh plugins, vim-plug)
make symlink   # Create symlinks to home directory
```

### Testing and Validation
```bash
# IMPORTANT: Always test configuration changes before committing
# Test zsh configuration syntax
zsh -n ~/.zshrc

# Reload and verify zsh configuration
zsh -c 'source ~/.zshrc && echo "OK"'

# Dry-run symlink creation to verify targets
make -n symlink

# Test zsh startup performance (built-in profiling)
# Set ENABLE_STARTUP_PROFILING=1 before starting new shell
ENABLE_STARTUP_PROFILING=1 zsh -i -c exit
```

## Architecture and Structure

### Configuration Management Pattern
- **Symlink-based**: All configuration files are symlinked from this repository to `~/.filename`
- **Platform-specific loading**: Main `zshrc` detects OS and sources appropriate platform files
- **Local overrides**: `zshrc.local` (created from `zshrc.local.sample`) for machine-specific settings

### Key Components

1. **Shell Environment (Zsh)**
   - Main config: `zshrc` - Core configuration with oh-my-zsh, peco/ghq integration
   - Platform configs: `zshrc.darwin` (macOS), `zshrc.linux` (Linux)
   - Performance optimizations: Lazy loading for heavy tools (nvm, pyenv), zcompile usage

2. **Development Tools Integration**
   - Git: Extensive aliases in `gitconfig`, git-secrets for AWS credential protection
   - Package managers: Homebrew (macOS), mise (version manager for multiple languages)
   - Terminal multiplexer: tmux with vim-like keybindings

3. **Editor Configurations**
   - NeoVim: Basic configuration with mini.deps support
   - IdeaVim: Inherits vimrc with additional IntelliJ-specific settings

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

#### Claude Code (`plugins/claudecode.lua`)
| キー | 説明 |
|------|------|
| `<Leader>l` | Claude Code トグル |
| `<Leader>la` | diff承認 |
| `<Leader>ld` | diff拒否 |
| `<Esc><Esc>` | Claude Code トグル (ターミナルモード) |

#### カスタムコマンド (`config/commands.lua`)
| コマンド | 説明 |
|----------|------|
| `:DailyLog` | 今日の日報ファイルを開く |
| `:JunkfileOpen` | タイムスタンプ付きメモファイル作成 |
| `:GHBrowse` | 現在行をGitHubで開く |

4. **Claude Code Configuration**
   - Custom commands: `claude/commands/` - commit, commit-and-pr, fix-issue, format-issue, enrich-issue, tidying
   - Custom agents: `claude/agents/` - tidy-first-refactorer
   - Symlinked to `~/.claude/commands/`, `~/.claude/agents/` etc.

### Important Patterns
- **Lazy loading**: Heavy tools are loaded on-demand to improve shell startup time
- **ghq + peco**: Repository management and navigation system (repos in `~/src`)
- **oh-my-zsh plugins**: Managed as git submodules in `oh-my-zsh/custom/plugins/`

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
- IMPORTANT: Platform-specific code must go in `zshrc.darwin` or `zshrc.linux`, not main `zshrc`
- Machine-specific settings belong in `zshrc.local` (not tracked in git)

### Git Practices
- YOU MUST test changes in a new shell session before committing
- Commit messages should explain the "why" for configuration changes
- Keep commits focused on a single logical change

## Repository Workflow

### Branch Strategy
- Branch naming: `feature/`, `fix/`, `chore/` prefixes
- IMPORTANT: Create feature branches from `master` branch
- Example: `feature/add-docker-aliases`, `fix/zsh-startup-time`

### Making Changes
1. Create a feature branch
2. Make changes to configuration files
3. Test changes using commands in "Testing and Validation" section
4. Commit with descriptive message
5. Create pull request for review (if working in team)

### Deployment
- IMPORTANT: After merging changes, run `make symlink` to update symlinks
- Reload shell with `source ~/.zshrc` or start a new shell session
- Verify no errors occur during shell initialization

## Critical Notes

1. **Git configuration**: YOU MUST update personal information in `gitconfig` before use:
   ```
   [user]
       name = your username on GitHub
       email = your email on GitHub
   ```
   IMPORTANT: Never commit with placeholder user information.

2. **SSH dependencies**: The Makefile clones repositories using SSH URLs (`git@github.com:`).
   YOU MUST have SSH keys set up before running `make deps`.

3. **macOS focus**: While Linux is supported, most optimizations and tool integrations are macOS-centric.
   Platform-specific code is isolated in `zshrc.darwin` and `zshrc.linux`.

## Known Issues and Warnings

- **Slow startup**: If shell startup is slow, check lazy-loading configuration in `zshrc`
- **oh-my-zsh submodules**: When cloning fresh, run `git submodule update --init --recursive`
- **Homebrew on Apple Silicon**: Some formulas may require Rosetta 2 or ARM-specific installation
- **tmux key conflicts**: Custom vim-like bindings may conflict with some terminal applications
