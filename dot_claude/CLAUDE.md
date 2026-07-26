# Conversation Guidelines

- 不明瞭な指示は質問して明確にする。

# Core Principles

## Core practices (always-on)
@rules/tidy-first.md
@rules/non-sycophancy.md
@rules/role-separation.md

## Coding workflow
@rules/commit-discipline.md
@rules/docs-lifecycle.md
@rules/git-branch-workflow.md
@rules/implementation-notes.md
@rules/delegation.md

## Specialty (必要時に Read で読む)

常駐させない。以下の場面に入ったら **着手前に必ず** 対応 rule を Read してから作業する:

- GitHub Issue / PR の作成・更新・レビューコメント応答: `~/.claude/rules/github-workflow.md`
- GitHub に文章を書く (issue / PR description / コメント): `~/.claude/rules/github-writing.md`
- 実装中〜PR 提出前のレビュー運用 (`/simplify` `/review` `/crit` `/security-review`): `~/.claude/rules/review-cycle.md`
- 計画・設計・作業分解フェーズの skill 選定: `~/.claude/rules/planning-workflow.md`
- ユーザーの判断基準・好み・過去の文脈が関わる話題 (brain MCP): `~/.claude/rules/brain-first.md`

# Env

- GitHub: saxsir
- リポジトリ: ghq 管理 (`~/src/github.com/owner/repo`)

# Tool Preferences

- MCP の配置先: OAuth / クラウド認証で完結するサービスは claude.ai Web 連携 MCP として設定する。localhost 依存または API token 認証が必要なものは `~/.claude.json` に登録する
- 大量・機械的なデータ取得に MCP を使わない (取得内容が全部モデルを通り token 消費が激しい)。CLI / API 直叩きの script に落として Claude の外で実行し、MCP は少数ファイルの探索・形式確認・トリアージまでに使う
- JSON の処理には Python ではなく `jq` を使う
- 個人プロジェクトの JS/TS ツールチェーンは bun をデフォルトにする (runtime / package manager / test runner)。新規プロジェクトは bun で始める。既存プロジェクトの移行は勝手に始めず提案に留める
- `gh api graphql` はエラー時も exit 0 を返す。必ずレスポンスの `.errors[]` を確認すること (理由: チェックしないと jq が invalid JSON を受け取って連鎖クラッシュする)
- AWS の認証情報を要するコマンド (`aws`, `terraform`, `cdk`, `boto3` 等) は `aws-vault exec <profile> -- <command>` で実行する (平文 credential の利用を避ける)。書き込み系は承認を得てから実行する (rules/role-separation.md 参照)
