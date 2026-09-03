PWD := $(shell pwd)

# make ghext で install する gh extension (OWNER/REPO を空白区切りで列挙)
GH_EXTENSIONS := github/gh-stack

.PHONY: all deps init apply diff edit re-add merge hooks mise uvtools macos apm ghext help

# デフォルト: 依存ツールを揃えて apply、mise install、pre-commit hook を install
all: deps apply mise uvtools hooks apm ghext

# Homebrew パッケージ (brew bundle) は macbook-provisioning の Brewfile で入れる
deps:
	@if [ -f package.json ]; then \
	  bun install --silent; \
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
#
# chezmoi re-add は仕様上 template (*.tmpl) を上書きせず、警告も出さずに no-op になる
# ("chezmoi will not overwrite templates")。そのため FILE の source が template の
# ときは自前で書き戻す: home path を {{ .chezmoi.homeDir }} に戻すだけなら機械的に
# 可逆なので sed で復元する (dot_claude/settings.json.tmpl がこのケース)。
# homeDir 以外のテンプレート変数を含む template ({{ .name }} を持つ dot_gitconfig.tmpl 等)
# は復元できないため、source を壊さずに abort して手動編集を促す。
re-add:
	@if [ -z "$(FILE)" ]; then \
	  chezmoi re-add --source "$(PWD)"; \
	else \
	  target=$$(printf '%s' "$(FILE)" | sed "s|^~|$(HOME)|"); \
	  src=$$(chezmoi source-path --source "$(PWD)" "$$target") || exit 1; \
	  case "$$src" in \
	    *.tmpl) \
	      others=$$(grep -o '{{[^}]*}}' "$$src" | grep -v '\.chezmoi\.homeDir' || true); \
	      if [ -n "$$others" ]; then \
	        echo "[re-add] $$src は homeDir 以外のテンプレート変数を含むため自動取り込みできません:"; \
	        printf '%s\n' "$$others" | sort -u | sed 's/^/  /'; \
	        echo "  source を直接編集してください"; \
	        exit 1; \
	      fi; \
	      tmp="$$(dirname "$$src")/.re-add.tmp"; \
	      sed "s|$(HOME)|{{ .chezmoi.homeDir }}|g" "$$target" > "$$tmp" && cat "$$tmp" > "$$src" || { rm -f "$$tmp"; exit 1; }; \
	      rm -f "$$tmp"; \
	      echo "[re-add] template として書き戻しました: $$target -> $$src"; \
	      chezmoi diff --source "$(PWD)" "$$target"; \
	      ;; \
	    *) chezmoi re-add --source "$(PWD)" "$$target";; \
	  esac; \
	fi

# ソースと target が両方変わって衝突したときの 3-way merge
# 例: make merge FILE=~/.zshrc
merge:
	@test -n "$(FILE)" || { echo "Usage: make merge FILE=~/.zshrc"; exit 1; }
	chezmoi merge --source "$(PWD)" "$(FILE)"

# mise でランタイムを ~/.config/mise/config.toml の宣言通りに揃える (apply 後に実行する想定)
mise:
	@command -v mise >/dev/null 2>&1 || { echo "mise が見つからない: make deps を先に実行"; exit 1; }
	mise install

# uv tool で global に入れる Python CLI を冪等に install (mise の pipx backend を使わず uv に寄せる)
uvtools:
	@command -v uv >/dev/null 2>&1 || { echo "uv が見つからない: make mise を先に実行"; exit 1; }
	uv tool install --upgrade kaggle

# apm (Agent Package Manager) を install して global skill を deploy する (冪等)
# Homebrew formula がないため公式 curl installer を使う
# ~/.apm/apm.yml の依存関係 (mattpocock/skills 等) を ~/.claude/skills/ へ展開する
# install は ~/.apm/apm.lock.yaml のコミット固定を尊重するため、update で常に最新へ追従させる
# apm update は ~/.claude/skills/ の apm 管理外 skill を削除するため、
# 巻き添えで消える Doist 公式 todoist-cli skill を毎回 td で復元する
# また apm は plugin の hook 登録 (hooks.json 経由の command 参照) だけを settings.json に
# 転記し、plugin ファイル本体は deploy しない。hook スクリプト (session-start 等) は実体
# が欠落するし、それらが plugin_root/skills など兄弟ディレクトリを参照する場合もあるので、
# plugin ディレクトリ全体を ~/.claude/hooks/<plugin>/ に同期する
apm:
	@if command -v apm >/dev/null 2>&1; then \
	  echo "[apm] already installed: $$(apm --version 2>&1 | head -1)"; \
	else \
	  echo "[apm] installing via curl installer..."; \
	  curl -sSL https://aka.ms/apm-unix | sh; \
	  echo "[apm] installed: $$(apm --version 2>&1 | head -1)"; \
	fi
	apm install -g --runtime claude
	apm update -g --yes
	@for plugdir in "$$HOME"/.apm/apm_modules/*/*; do \
	  [ -d "$$plugdir/hooks" ] || continue; \
	  plugin=$$(basename "$$plugdir"); \
	  dst="$$HOME/.claude/hooks/$$plugin"; \
	  mkdir -p "$$dst"; \
	  cp -pR "$$plugdir"/. "$$dst"/; \
	  echo "[apm] synced plugin dir: $$plugdir -> $$dst"; \
	done
	@if command -v td >/dev/null 2>&1; then \
	  td skill install claude-code --force; \
	else \
	  echo "[apm] td が見つからないため todoist-cli skill の復元をスキップ"; \
	fi

# GH_EXTENSIONS に列挙した gh extension を install する (冪等)
# gh 未認証だと install が API アクセスで失敗するため、その場合はスキップして通知だけする
ghext:
	@command -v gh >/dev/null 2>&1 || { echo "gh が見つからない: make deps を先に実行"; exit 1; }
	@if gh auth status >/dev/null 2>&1; then \
	  for ext in $(GH_EXTENSIONS); do \
	    if gh extension list 2>/dev/null | grep -q "$$ext"; then \
	      echo "[ghext] already installed: $$ext"; \
	    else \
	      gh extension install "$$ext"; \
	    fi; \
	  done; \
	else \
	  echo "[ghext] gh が未認証のためスキップ (gh auth login 後に make ghext)"; \
	fi

# macOS defaults を ~/.macos に従って一括適用する (デフォルト all には含めない: 副作用大)
# 適用前に内容を確認するなら `cat ~/.macos`
macos:
	@[ "$$(uname)" = "Darwin" ] || { echo "macOS 専用です"; exit 1; }
	@[ -x "$(HOME)/.macos" ] || { echo "~/.macos が無い: make apply を先に実行"; exit 1; }
	"$(HOME)/.macos"

help:
	@echo "Targets:"
	@echo "  all      - deps + apply + mise + hooks + apm + ghext (デフォルト)"
	@echo "  deps     - bun install (Homebrew は macbook-provisioning の Brewfile で導入)"
	@echo "  init     - 初回のみ chezmoi 設定ファイルを生成"
	@echo "  apply    - source → ~/ に反映 (標準の方向)"
	@echo "  diff     - apply 前の差分確認"
	@echo "  edit     - source 側を編集して --apply (FILE=...)"
	@echo "  re-add   - ~/ の編集内容を source に取り込み (FILE=... 任意、template も対応)"
	@echo "  merge    - 衝突時の 3-way merge (FILE=...)"
	@echo "  mise     - ~/.config/mise/config.toml に従って mise install"
	@echo "  uvtools  - uv tool で global に入れる Python CLI (kaggle 等) を install"
	@echo "  macos    - ~/.macos の defaults を一括適用 (副作用大のため all には含めない)"
	@echo "  hooks    - pre-commit hook を install (secretlint)"
	@echo "  apm      - apm CLI を install + ~/.apm/apm.yml の skill を最新コミットで deploy (冪等)"
	@echo "  ghext    - GH_EXTENSIONS の gh extension を install (冪等)"
