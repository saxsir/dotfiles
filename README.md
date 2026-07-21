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
- `Brewfile` — 依存パッケージ (chezmoi/starship/pre-commit/bun + フォント) を `brew bundle` で管理
- `.pre-commit-config.yaml` / `.secretlintrc.json` / `package.json` — secretlint によるコミット時シークレット検出
- `.chezmoiignore` — リポメタ (`Makefile` / `README.md` / `Brewfile` / `lima` / `misc` 等) を chezmoi 適用対象から除外
- `lima/`, `misc/` — chezmoi 管理外 (リポメタ)

## 主なコマンド

```
make             # = make deps apply hooks
make deps        # brew bundle + bun install (Brewfile + package.json)
make apply       # chezmoi apply (~/ にファイル配置)
make diff        # 適用前に差分確認
make hooks       # pre-commit hook を install
make help        # 全 target 一覧
```

## apm (Agent Package Manager)

`make apm`（または `make` 全体）で公式インストーラーを冪等に呼んで導入される。

```
make apm   # 未 install なら curl -sSL https://aka.ms/apm-unix | sh を実行、既存なら skip
```

ユーザー global 設定 `~/.apm/config.json` は `private_dot_apm/config.json` として chezmoi 管理。
設定を編集した場合は `make re-add FILE=~/.apm/config.json` でソース側に取り込む。

## シークレット検出

`pre-commit install` 後は `git commit` 時に `secretlint` が自動的に走り、AWS キーや GitHub トークン等が混入していると commit が失敗します。手動チェック:

```
bunx secretlint "**/*"
```

## シークレット暗号化 (任意)

機密ファイル (AWS credentials / GitHub token 等) を `encrypted_*` プレフィックス付きで chezmoi 管理に取り込みたい場合は age を使う。秘密鍵は **dotfiles リポには絶対 commit しない** こと。

### 初回セットアップ

```bash
# 1. age と age-keygen を入れる (Brewfile 同梱)
make deps

# 2. age 鍵ペアを生成
mkdir -p ~/.config/chezmoi
age-keygen -o ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt

# 3. 公開鍵 (recipient) を表示してコピー
age-keygen -y ~/.config/chezmoi/key.txt
# 例: age1abcdefg...

# 4. chezmoi に recipient を登録 (再 init で `Age recipient` プロンプトに貼り付け)
chezmoi init --source "$(pwd)"

# 5. 秘密鍵を別途バックアップ (USB / 別マシン等)
cp ~/.config/chezmoi/key.txt /Volumes/USB/age-key-backup.txt
```

### 暗号化済みファイルを追加

```bash
# 既存ファイルを暗号化して chezmoi 管理に取り込む
chezmoi add --encrypt ~/.aws/credentials
# → source dir に encrypted_private_dot_aws/credentials.age が生成される

# 編集 (一時復号 → 編集 → 再暗号化を chezmoi がよしなにやる)
chezmoi edit ~/.aws/credentials
```

### 復元 (新マシン)

1. `make deps` で age を入れる
2. バックアップから秘密鍵を復元 (`cp /Volumes/USB/age-key-backup.txt ~/.config/chezmoi/key.txt && chmod 600 ~/.config/chezmoi/key.txt`)
3. `chezmoi init` で recipient プロンプトに公開鍵を貼り付け (バックアップに併記しておくとラク)
4. `make apply` で復号 + 配置
