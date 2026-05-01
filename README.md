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
- `.chezmoiignore` — `Makefile` / `README.md` / `lima/` / `misc/` 等を chezmoi 適用対象から除外
- `lima/`, `misc/` — chezmoi 管理外 (リポメタ)

## 主なコマンド

```
make             # = make deps apply
make deps        # brew で chezmoi/starship/font 等を揃える
make apply       # chezmoi apply (~/ にファイル配置)
make diff        # 適用前に差分確認
chezmoi edit ~/.zshrc   # ソース側を編集 (apply は別途)
```
