# Conversation Guidelines

- ユーザーには日本語で応答する。思考は英語可。
- 不明瞭な指示は質問して明確にする。

# Core Principles

## Core practices (always-on)
@rules/tdd.md
@rules/tidy-first.md
@rules/non-sycophancy.md
@rules/verification-by-declaration.md
@rules/role-separation.md

## Coding workflow
@rules/commit-discipline.md
@rules/git-branch-workflow.md
@rules/implementation-notes.md
@rules/delegation.md

## Specialty (task-specific)
@rules/github-workflow.md
@rules/github-writing.md
@rules/review-cycle.md
@rules/planning-workflow.md
@rules/brain-first.md

# Env

- GitHub: saxsir
- リポジトリ: ghq 管理 (`~/src/github.com/owner/repo`)

# Tool Preferences

- MCP の配置先: OAuth / クラウド認証で完結するサービスは claude.ai Web 連携 MCP として設定する。localhost 依存または API token 認証が必要なものは `~/.claude.json` に登録する
- 大量・機械的なデータ取得に MCP を使わない (取得内容が全部モデルを通り token 消費が激しい)。CLI / API 直叩きの script に落として Claude の外で実行し、MCP は少数ファイルの探索・形式確認・トリアージまでに使う
- JSON の処理には Python ではなく `jq` を使う
- `gh api graphql` はエラー時も exit 0 を返す。必ずレスポンスの `.errors[]` を確認すること (理由: チェックしないと jq が invalid JSON を受け取って連鎖クラッシュする)
- AWS の認証情報を要するコマンド (`aws`, `terraform`, `cdk`, `boto3` 等) は `aws-vault exec <profile> -- <command>` で実行する (平文 credential の利用を避ける)

# Maintenance

- `/audit-context` でグローバル設定 (CLAUDE.md / rules / ローカル MCP) のサイズ棚卸しができる。たまに思い出して実行する。
