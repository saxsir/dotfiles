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
- @rules/implementation-notes.md — 実装タスクで Implementation Notes (.claude/notes/*.html) を生成
- @rules/parallelization-and-subagents.md — 並列化と subagent（default は subagent 優先 / 並列優先）
- @rules/model-tiering.md — モデル階層（Fable 時は小タスクを Sonnet subagent に委譲し、自分はレビューに専念）
- @rules/planning-workflow.md — 計画・設計のデフォルトレール（収束は mattpocock grill-with-docs→to-issues 寄り / superpowers は実行層）
- @rules/non-sycophancy.md — 迎合の回避（根拠で応答し、ユーザーの提案にも即同意しない）
- @rules/verification-by-declaration.md — 形名参同（完了条件を宣言し、実行確認してから完了と主張）
- @rules/role-separation.md — 過程と結果の分離（不可逆操作はユーザーに委ねる）
- @rules/brain-first.md — Brain-First（判断基準・過去の文脈が関わる話題は行動前に brain_ask で外部脳に問い合わせる）

# Env

- GitHub: saxsir
- リポジトリ: ghq 管理（`~/src/github.com/owner/repo`）

# Tool Preferences

- MCP の配置先: OAuth / クラウド認証で完結するサービスは claude.ai Web 連携 MCP として設定する。localhost 依存または API token 認証が必要なものは `~/.claude.json` に登録する
- 大量・機械的なデータ取得に MCP を使わない（取得内容が全部モデルを通り token 消費が激しい）。CLI / API 直叩きの script に落として Claude の外で実行し、MCP は少数ファイルの探索・形式確認・トリアージまでに使う
- JSON の処理には Python ではなく `jq` を使う
- `gh api graphql` はエラー時も exit 0 を返す。必ずレスポンスの `.errors[]` を確認すること（理由: チェックしないと jq が invalid JSON を受け取って連鎖クラッシュする）
- AWS の認証情報を要するコマンド (`aws`, `terraform`, `cdk`, `boto3` 等) は `aws-vault exec <profile> -- <command>` で実行する (平文 credential の利用を避ける)

# Maintenance

- `/audit-context` でグローバル設定（CLAUDE.md / rules / ローカル MCP）のサイズ棚卸しができる。たまに思い出して実行する。