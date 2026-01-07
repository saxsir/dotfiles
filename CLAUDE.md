# CLAUDE.md

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

### Common Development Tasks
```bash
# Reload shell configuration after changes
source ~/.zshrc

# Test zsh startup performance (built-in profiling)
# Set ENABLE_STARTUP_PROFILING=1 before starting new shell
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
   - Vim: Basic configuration with vim-plug support
   - IdeaVim: Inherits vimrc with additional IntelliJ-specific settings

### Important Patterns
- **Lazy loading**: Heavy tools are loaded on-demand to improve shell startup time
- **ghq + peco**: Repository management and navigation system (repos in `~/src`)
- **oh-my-zsh plugins**: Managed as git submodules in `oh-my-zsh/custom/plugins/`

## Critical Notes

1. **User-specific paths**: Some configurations contain hardcoded paths (e.g., `/Users/ca00622`). These should be reviewed and updated as needed.

2. **Git configuration**: The `gitconfig` contains personal user information that MUST be changed before use:
   ```
   [user]
       name = your username on GitHub
       email = your email on GitHub
   ```

3. **SSH dependencies**: The Makefile clones repositories using SSH URLs (`git@github.com:`), requiring SSH keys to be set up.

4. **macOS focus**: While Linux is supported, most optimizations and tool integrations are macOS-centric.