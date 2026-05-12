# Conversation Guidelines

- ユーザーには日本語で応答する。思考は英語可。
- 不明瞭な指示は質問して明確にする。

# Core Principles

以下のプラクティスを常に守る:

- @rules/tdd.md — TDD サイクル (Red → Green → Refactor)
- @rules/tidy-first.md — Tidy First (構造変更と振る舞い変更の分離)
- @rules/commit-discipline.md — コミット規律
- @rules/code-quality.md — コード品質基準
- @rules/git-branch-workflow.md — Git ブランチワークフロー
- @rules/github-workflow.md — GitHub ワークフロー (Issue / PR / レビュー)

# Env

- GitHub: saxsir
- リポジトリ: ghq 管理（`~/src/github.com/owner/repo`）
- 別リポジトリ操作時に sandbox エラー (`Operation not permitted`) が出ても `dangerouslyDisableSandbox: true` を勝手に使わない。`/sandbox` コマンドで許可リストにパスを追加して対応する（理由: sandbox を広げる判断はユーザーが行う）

# Tool Preferences

- JSON の処理には Python ではなく `jq` を使う
- `gh api graphql` はエラー時も exit 0 を返す。必ずレスポンスの `.errors[]` を確認すること（理由: チェックしないと jq が invalid JSON を受け取って連鎖クラッシュする）
- AWS の認証情報を要するコマンド (`aws`, `terraform`, `cdk`, `boto3` 等) は `aws-vault exec <profile> -- <command>` で実行する (平文 credential の利用を避ける)

# Maintenance

- `/audit-context` でグローバル設定（CLAUDE.md / rules / ローカル MCP）のサイズ棚卸しができる。たまに思い出して実行する。
