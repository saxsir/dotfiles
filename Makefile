PWD := $(shell pwd)

.PHONY: all deps init apply diff edit re-add merge help

# デフォルト: 依存ツールを揃えて apply
all: deps apply

deps:
	@command -v brew >/dev/null 2>&1 || { echo "Homebrew が必要です: https://brew.sh"; exit 1; }
	@command -v chezmoi >/dev/null 2>&1 || brew install chezmoi
	@command -v starship >/dev/null 2>&1 || brew install starship
	@brew install --cask font-plemol-jp-nf 2>/dev/null || true

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

help:
	@echo "Targets:"
	@echo "  all      - deps + apply (デフォルト)"
	@echo "  deps     - brew で chezmoi/starship/font をインストール"
	@echo "  init     - 初回のみ chezmoi 設定ファイルを生成"
	@echo "  apply    - source → ~/ に反映 (標準の方向)"
	@echo "  diff     - apply 前の差分確認"
	@echo "  edit     - source 側を編集して --apply (FILE=...)"
	@echo "  re-add   - ~/ の編集内容を source に取り込み (FILE=... 任意)"
	@echo "  merge    - 衝突時の 3-way merge (FILE=...)"
