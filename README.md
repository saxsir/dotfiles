dotfiles
========

設定ファイルとかとか。[chezmoi](https://www.chezmoi.io/) で管理。

## Run

```
$ make
```

初回は Homebrew で chezmoi をインストールし、Git の `user.name` / `user.email` をプロンプトで聞かれる。
入力した値は `~/.config/chezmoi/chezmoi.toml` に保存される (gitconfig は `dot_gitconfig.tmpl` で template 展開)。

## Layout

- リポジトリルート — chezmoi の source root (`dot_*` / `*.tmpl` 等が並ぶ)
- `Makefile` — `chezmoi apply` のエントリポイントと依存ツール (brew 等) のインストール
- `Brewfile` — 依存パッケージ (chezmoi/starship/pre-commit/node + フォント) を `brew bundle` で管理
- `.pre-commit-config.yaml` / `.secretlintrc.json` / `package.json` — secretlint によるコミット時シークレット検出
- `.chezmoiignore` — リポメタ (`Makefile` / `README.md` / `Brewfile` / `lima` / `misc` 等) を chezmoi 適用対象から除外
- `lima/`, `misc/` — chezmoi 管理外 (リポメタ)

## 主なコマンド

```
make             # = make deps apply hooks
make deps        # brew bundle + npm install (Brewfile + package.json)
make apply       # chezmoi apply (~/ にファイル配置)
make diff        # 適用前に差分確認
make hooks       # pre-commit hook を install
make help        # 全 target 一覧
```

## シークレット検出

`pre-commit install` 後は `git commit` 時に `secretlint` が自動的に走り、AWS キーや GitHub トークン等が混入していると commit が失敗します。手動チェック:

```
npx secretlint "**/*"
```
