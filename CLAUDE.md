# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

macOS (Darwin) 中心の個人 dotfiles リポジトリ。Linux もサポートするが、最適化とツール統合の多くは macOS 前提になっている。管理は [chezmoi](https://www.chezmoi.io/) で、Makefile は `chezmoi apply` と mise / apm の適用を呼ぶだけの薄いラッパー (Homebrew と Brewfile は saxsir/macbook-provisioning が担当)。

## Essential Commands

```bash
make           # deps + apply
make deps      # bun install (package.json があれば。Homebrew 導入は macbook-provisioning が担当)
make apply     # chezmoi apply で ~/ にファイル配置 (初回は init で name/email プロンプト)
make diff      # 適用前に差分確認
make apm       # ~/.claude/skills/ と ~/.agents/skills/ へ skill をデプロイ (内部で apm update -g --yes)
```

設定を触ったら、コミット前に反映して動くことを見ておきたい。zsh なら `zsh -n ~/.zshrc` で構文を見て、新しいシェルを開いて初期化がエラーなく通るか確かめる。起動時間が気になるときは `ENABLE_STARTUP_PROFILING=1 zsh -i -c exit` で内蔵プロファイラが回る。chezmoi の適用結果を先に見たいときは `chezmoi diff`。

## Architecture and Structure

### Configuration Management Pattern

- **chezmoi-based**: リポジトリルートが chezmoi の source root。`chezmoi apply` でホームディレクトリに実ファイルとして配置される
- **Local overrides**: `zshrc.local` は `create_dot_zshrc.local` 由来。`create_` prefix のため初回のみ作成され、既存ファイルは上書きされない (machine-specific 設定の保護)
- **gitconfig template**: `dot_gitconfig.tmpl` が `{{ .name }}` / `{{ .email }}` を参照する。値は初回 `chezmoi init` で対話入力され `~/.config/chezmoi/chezmoi.toml` に入るので、リポジトリ側に個人情報は含まれない
- **chezmoi 管理外**: `Makefile`, `README.md`, `LICENSE`, `lima/`, `misc/` 等のリポメタは `.chezmoiignore` で適用対象から除外
- **新規ディレクトリを足すとき**: 先に既存の source dir を確認する。`private_dot_X/` があるのに `dot_X/` を別に作ると `chezmoi apply` が競合エラーになるので、その場合は既存の `private_dot_X/` に足す

### Key Components

1. **Shell (Zsh)**: `dot_zshrc` が本体。zinit (プラグインマネージャ、`dot_zshrc` 内で自己 clone する) と peco/ghq 連携。nvm や pyenv のような重いツールは lazy loading と zcompile で起動時間を抑えている。起動が遅いときはこの辺りを見る
2. **Development Tools**: git は `gitconfig` に大量のエイリアスがあり、AWS credential 保護に git-secrets を使う。パッケージ管理は Homebrew (macOS) と mise (言語バージョン管理)
3. **Editors**: NeoVim は mini.deps ベースの基本構成。IdeaVim は vimrc を継承しつつ IntelliJ 固有の設定を足している
4. **Lima VM**: `lima/claude-dev.yaml` が Claude Code 実行用 VM (Ubuntu 24.04 ARM64, Apple Virtualization.framework)。ホストの `~/src` を読み書き可能でマウントし、ホームは読み取り専用
5. **Agent Skills (apm)**: `private_dot_apm/apm.yml` の `dependencies.apm` に `owner/repo` を追記し、`make apply` で `~/.apm/apm.yml` に反映してから `make apm`。`targets` が `claude` と `agent-skills` の両方なので、apm 管理下の skill は `~/.claude/skills/` (Claude Code) と `~/.agents/skills/` (Codex CLI の user scope) の両方に展開される (apm 管理外の todoist-cli は `~/.claude/skills/` だけ)

## Code Style

Shell script は 2-space indent で、変数も関数も lowercase_with_underscores。変数展開は `"${variable}"` の形でクォートする (単語分割と glob 展開の事故を防ぐため)。

OS 依存の分岐が必要になったら、その場で条件分岐を書かずに chezmoi template 化して `{{ if eq .chezmoi.os "darwin" }}` で分ける。マシン固有の設定は `~/.zshrc.local` に置く。

macOS には Homebrew 経由で GNU coreutils が入っている。`date` 等は GNU 版なので、コマンドを提案するときは GNU 構文 (`date -d`, `date +%s`) で書く。

## Repository Workflow

ブランチは `feat/` `fix/` `chore/` prefix で、`master` から切る (default branch が master であることに注意)。PR 運用と description の書き方はグローバルの `rules/github-workflow.md` に従う。個人リポジトリでも draft PR を経由し、merge はユーザーが行う。

merge した変更を `~/` に反映するには `make apply` が要る。ただし **Claude からは `chezmoi apply` を実行できない** — `~/.config/chezmoi/chezmoistate.boltdb` が sandbox の allowOnly 外にあるため。`dot_claude/` 等を編集した後は、ユーザーにターミナルで `! make apply` を実行してもらう。適用後はシェルを開き直して初期化が通ることを確認する。

## Agent skills

- **Issue tracker**: Issues と PRD は `.scratch/<feature>/` 配下の markdown ファイルで管理する。See `docs/agents/issue-tracker.md`
- **Triage labels**: 5 つの正規 triage ロールを既定の文字列 (`needs-triage` 等) で使う。See `docs/agents/triage-labels.md`
- **Domain docs**: Single-context レイアウト (ルートに `CONTEXT.md` + `docs/adr/`)。See `docs/agents/domain.md`
