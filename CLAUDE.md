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
   - Package managers: Homebrew (macOS), various language version managers (rbenv, pyenv, nodebrew)
   - Terminal multiplexer: tmux with vim-like keybindings

3. **Editor Configurations**
   - NeoVim: Basic configuration with mini.deps support
   - IdeaVim: Inherits vimrc with additional IntelliJ-specific settings

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
