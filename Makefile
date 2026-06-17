PWD := $(shell pwd)

.PHONY: all deps init apply diff edit re-add merge hooks mise macos apm help

# デフォルト: 依存ツールを揃えて apply、mise install、pre-commit hook を install
all: deps apply mise hooks apm

deps:
	@command -v brew >/dev/null 2>&1 || { echo "Homebrew が必要です: https://brew.sh"; exit 1; }
	brew bundle --file=Brewfile
	@if [ -f package.json ]; then \
	  npm install --silent; \
	fi

# pre-commit hook を .git/hooks にインストール (secretlint 等を有効化)
# core.hooksPath が孤児パス (実体なし) を指している場合は自動で unset する。
# 実体があるパスを指している場合はユーザに通知して abort (意図的な設定の上書きを避ける)。
hooks:
	@command -v pre-commit >/dev/null 2>&1 || { echo "pre-commit が見つからない: make deps を先に実行"; exit 1; }
	@hp=$$(git config --get core.hooksPath 2>/dev/null); \
	if [ -n "$$hp" ]; then \
	  if [ ! -d "$$hp" ]; then \
	    echo "[hooks] 孤児な core.hooksPath ($$hp) を unset します"; \
	    git config --unset core.hooksPath; \
	  else \
	    echo "[hooks] core.hooksPath=$$hp が設定済みです。pre-commit と共存するか手動で対応してください:"; \
	    echo "  git config --unset core.hooksPath  # pre-commit を使う"; \
	    exit 1; \
	  fi; \
	fi
	pre-commit install

# 初回のみ: chezmoi の設定ファイル ~/.config/chezmoi/chezmoi.toml を生成
init:
	chezmoi init --source "$(PWD)"

# ソース → ~/ に反映 (chezmoi 標準の方向)
apply:
	@if [ ! -f "$(HOME)/.config/chezmoi/chezmoi.toml" ]; then \
	  $(MAKE) init; \
	fi
	chezmoi apply --source "$(PWD)"

# apply 前の差分確認
diff:
	chezmoi diff --source "$(PWD)"

# ソース側を $EDITOR で編集 (FILE=~/.zshrc など)。--apply で同時に ~/ にも反映
# 例: make edit FILE=~/.zshrc
edit:
	@test -n "$(FILE)" || { echo "Usage: make edit FILE=~/.zshrc"; exit 1; }
	chezmoi edit --apply --source "$(PWD)" "$(FILE)"

# ~/ で直接編集した内容を ソース側に取り込む (target → source)
# FILE 未指定なら全 managed file を一括取り込み
# 例: make re-add FILE=~/.zshrc / make re-add
re-add:
	chezmoi re-add --source "$(PWD)" $(FILE)

# ソースと target が両方変わって衝突したときの 3-way merge
# 例: make merge FILE=~/.zshrc
merge:
	@test -n "$(FILE)" || { echo "Usage: make merge FILE=~/.zshrc"; exit 1; }
	chezmoi merge --source "$(PWD)" "$(FILE)"

# mise でランタイムを ~/.config/mise/config.toml の宣言通りに揃える (apply 後に実行する想定)
mise:
	@command -v mise >/dev/null 2>&1 || { echo "mise が見つからない: make deps を先に実行"; exit 1; }
	mise install

# apm (Agent Package Manager) を install して global skill を deploy する (冪等)
# Homebrew formula がないため公式 curl installer を使う
# ~/.apm/apm.yml の依存関係 (mattpocock/skills 等) を ~/.claude/skills/ へ展開する
apm:
	@if command -v apm >/dev/null 2>&1; then \
	  echo "[apm] already installed: $$(apm --version 2>&1 | head -1)"; \
	else \
	  echo "[apm] installing via curl installer..."; \
	  curl -sSL https://aka.ms/apm-unix | sh; \
	  echo "[apm] installed: $$(apm --version 2>&1 | head -1)"; \
	fi
	apm install -g --runtime claude

# macOS defaults を ~/.macos に従って一括適用する (デフォルト all には含めない: 副作用大)
# 適用前に内容を確認するなら `cat ~/.macos`
macos:
	@[ "$$(uname)" = "Darwin" ] || { echo "macOS 専用です"; exit 1; }
	@[ -x "$(HOME)/.macos" ] || { echo "~/.macos が無い: make apply を先に実行"; exit 1; }
	"$(HOME)/.macos"

help:
	@echo "Targets:"
	@echo "  all      - deps + apply + mise + hooks + apm (デフォルト)"
	@echo "  deps     - brew bundle + npm install"
	@echo "  init     - 初回のみ chezmoi 設定ファイルを生成"
	@echo "  apply    - source → ~/ に反映 (標準の方向)"
	@echo "  diff     - apply 前の差分確認"
	@echo "  edit     - source 側を編集して --apply (FILE=...)"
	@echo "  re-add   - ~/ の編集内容を source に取り込み (FILE=... 任意)"
	@echo "  merge    - 衝突時の 3-way merge (FILE=...)"
	@echo "  mise     - ~/.config/mise/config.toml に従って mise install"
	@echo "  macos    - ~/.macos の defaults を一括適用 (副作用大のため all には含めない)"
	@echo "  hooks    - pre-commit hook を install (secretlint)"
	@echo "  apm      - apm CLI を install + ~/.apm/apm.yml の skill を deploy (冪等)"
