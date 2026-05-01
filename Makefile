PWD := $(shell pwd)

.PHONY: all deps apply diff init

all: deps apply

deps:
	@command -v brew >/dev/null 2>&1 || { echo "Homebrew が必要です: https://brew.sh"; exit 1; }
	@command -v chezmoi >/dev/null 2>&1 || brew install chezmoi
	@command -v starship >/dev/null 2>&1 || brew install starship
	@brew install --cask font-plemol-jp-nf 2>/dev/null || true

# 初回のみ: chezmoi の設定ファイル ~/.config/chezmoi/chezmoi.toml を生成
init:
	chezmoi init --source "$(PWD)"

# ソースに対して apply (~/ への配置)
apply:
	@if [ ! -f "$(HOME)/.config/chezmoi/chezmoi.toml" ]; then \
	  $(MAKE) init; \
	fi
	chezmoi apply --source "$(PWD)"

diff:
	chezmoi diff --source "$(PWD)"
