dotfiles
========

設定ファイルとかとか。[chezmoi](https://www.chezmoi.io/) で管理。

## Run

前提: [saxsir/macbook-provisioning](https://github.com/saxsir/macbook-provisioning) の `make` を先に実行する (Homebrew と Brewfile、macOS defaults はそちらが担当する)。このリポジトリの `make` は chezmoi apply と mise / apm の適用だけを行う。

```
$ make
```

初回は chezmoi の設定ファイルが無いため `chezmoi init` が走り、Git の `user.name` / `user.email` をプロンプトで聞かれる。
入力した値は `~/.config/chezmoi/chezmoi.toml` に保存される (gitconfig は `dot_gitconfig.tmpl` で template 展開)。

## Layout

- リポジトリルート — chezmoi の source root (`dot_*` / `*.tmpl` 等が並ぶ)
- `Makefile` — `chezmoi apply` のエントリポイントと mise / apm 適用の呼び出し (Homebrew と Brewfile は macbook-provisioning が担当)
- `.pre-commit-config.yaml` / `.secretlintrc.json` / `package.json` — secretlint によるコミット時シークレット検出
- `.chezmoiignore` — リポメタ (`Makefile` / `README.md` / `lima` / `misc` 等) を chezmoi 適用対象から除外
- `lima/`, `misc/` — chezmoi 管理外 (リポメタ)

## 主なコマンド

```
make             # = make deps apply hooks
make deps        # bun install (package.json があれば。Homebrew は macbook-provisioning が担当)
make apply       # chezmoi apply (~/ にファイル配置)
make diff        # 適用前に差分確認
make apm-bump    # apm.yml の pin を各 repo の HEAD へ更新 (PKG=owner/repo で限定)
make hooks       # pre-commit hook を install
make help        # 全 target 一覧
```

## apm (Agent Package Manager)

`make apm`（または `make` 全体）で公式インストーラーを冪等に呼んで導入される。

```
make apm   # 未 install なら curl -sSL https://aka.ms/apm-unix | sh を実行、既存なら skip
```

skill の展開先は `private_dot_apm/apm.yml` の `targets` で決まる。`claude` と `agent-skills` を並べているので、
apm 管理下の skill は `~/.claude/skills/` (Claude Code) と `~/.agents/skills/` (Codex CLI が user scope として
読む場所) の両方に入る。Codex 側は追加設定なしでそのまま使える。apm 管理外の todoist-cli skill は
`td` が Claude Code 向けにしか復元しないため `~/.claude/skills/` だけに入る。

`targets` を書き換えたときは `make apply` で `~/.apm/apm.yml` に反映してから `make apm` を実行する。
`make apm` の中の `apm install -g` は `~/.apm/apm.yml` を見るので、反映前だと展開先が食い違う。

依存は `private_dot_apm/apm.yml` で `owner/repo[/subpath]#<40桁SHA>` に pin する。`make apm` は pin どおりの SHA を `apm install -g` で入れるだけで、`apm update` は使わない (pin の無い依存を毎回 upstream に解決して遅く、pin もリリースタグへ書き換えるため)。

pin を各 repo の default branch の HEAD へ進めるには `make apm-bump` を実行する (`PKG=saxsir/skills` で 1 repo に限定)。source の apm.yml の SHA だけを書き換えるので、`make apply apm` で反映する。依存を追加するときは SHA 付きで書くか、追記後に `make apm-bump PKG=owner/repo` で SHA を入れる。

ユーザー global 設定 `~/.apm/config.json` は `private_dot_apm/config.json` として chezmoi 管理。
設定を編集した場合は `make re-add FILE=~/.apm/config.json` でソース側に取り込む。

## MCP の allowlist

セッション開始時に読み込む MCP を `allowedMcpServers` で絞っている。claude.ai 連携 MCP は tool 名一覧と server instructions が context に載るので、使わない連携を読み込まないぶん固定費が減る。

allowlist は 2 層で持ち、settings の scope をまたいで union になる。

- user settings (`dot_claude/settings.json.tmpl`) は全リポジトリ共通の baseline を持つ。`chrome-devtools`、`cmux-cua` (cmux が `--mcp-config` で渡す)、claude.ai Slack が対象
- 各リポジトリの `.claude/settings.local.json` は、そのリポジトリで使う server を足す。gitignore 済みで chezmoi の管理外なので、リポジトリ固有の名前や host を dotfiles に置かずに済む

main checkout の `.claude/settings.local.json` は linked worktree にも効く。仕様は [Claude Code のドキュメント](https://code.claude.com/docs/en/managed-mcp) にある。

### 注意

- allowlist から外れた server は、`/mcp` にも `claude mcp list` にも理由の表示なしに消える。MCP が見当たらないときは、まず allowlist を疑う
- 新しく足した MCP (plugin が持つものを含む) も、どこかの allowlist に書くまで使えない
- `deniedMcpServers` は allow より常に優先され、下位の scope から戻せない。リポジトリ単位で有効にしたい server は deny に入れず、allowlist に足して運用する

### リポジトリに server を足す

リポジトリの `.claude/settings.local.json` に `allowedMcpServers` を書く。既存のキーは残す。

```json
{
  "allowedMcpServers": [
    { "serverUrl": "https://mcp.example.com/mcp" },
    { "serverName": "example-stdio-server" }
  ]
}
```

書き方の規則は次のとおり。

- remote server (claude.ai 連携、`.mcp.json` の http、local scope の http) は `serverUrl`、stdio server は `serverName` で書く
- `serverCommand` は使わない。1 つでも書くと、stdio server も `serverName` で照合されなくなる
- `serverName` に使えるのは `[A-Za-z0-9_-]` だけで、`claude.ai Slack` のような連携名は書けない
- allowlist に `serverUrl` が 1 つでもあると remote server は `serverName` で照合されない。baseline に claude.ai Slack の `serverUrl` があるので、どのリポジトリでもこの状態になる
- `serverUrl` は query を含めた完全一致で照合される

### URL の調べ方

- claude.ai 連携は、user と local の settings を外して一覧する。allowlist から外れた連携は通常の `claude mcp list` に出ないためだ。stdio server の行は command line ごと表示され token を含みうるので、URL の行だけに絞る

  ```
  claude --setting-sources project mcp list | awk -F': ' '$2 ~ /^https?:\/\// { sub(/ - .*$/, ""); print }'
  ```

- `.mcp.json` の http server は、`url` の値を写す
- local scope の http server は `~/.claude.json` の `projects` 配下にある。URL に token が含まれることがあるので、画面や共有先に出さない

  ```
  jq '.projects["<リポジトリの絶対パス>"].mcpServers | map_values(.url)' ~/.claude.json
  ```

### 同じ host に 2 つあるとき

claude.ai 連携と `.mcp.json` の server が同じ host にあるときは、残したい側の URL を完全一致で書く。

- query が違うとき (`.mcp.json` 側が query で tool を絞った `https://mcp.example.com/mcp?toolsets=core`、連携側が query 無しの `https://mcp.example.com/mcp`) は、query 込みの URL を書くと `.mcp.json` 側だけが残り、query 無しの URL を書くと連携側だけが残る
- URL がまったく同じときは、`.mcp.json` の server が有効なら (`disabledMcpjsonServers` で無効にしていなければ) 同じ URL の claude.ai 連携は表示されず、無効にしていれば連携側が表示される
- plugin が持つ server は別で、連携と plugin の両方が表示される

## シークレット検出

`pre-commit install` 後は `git commit` 時に `secretlint` が自動的に走り、AWS キーや GitHub トークン等が混入していると commit が失敗します。手動チェック:

```
bunx secretlint "**/*"
```

## シークレット暗号化 (任意)

機密ファイル (AWS credentials / GitHub token 等) を `encrypted_*` プレフィックス付きで chezmoi 管理に取り込みたい場合は age を使う。秘密鍵は **dotfiles リポには絶対 commit しない** こと。

### 初回セットアップ

```bash
# 1. age と age-keygen を入れる (macbook-provisioning の Brewfile で導入する)

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

1. macbook-provisioning の `make` で age を入れる (Homebrew の Brewfile 経由)
2. バックアップから秘密鍵を復元 (`cp /Volumes/USB/age-key-backup.txt ~/.config/chezmoi/key.txt && chmod 600 ~/.config/chezmoi/key.txt`)
3. `chezmoi init` で recipient プロンプトに公開鍵を貼り付け (バックアップに併記しておくとラク)
4. `make apply` で復号 + 配置
