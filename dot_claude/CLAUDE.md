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
- @rules/verification-by-declaration.md — 形名参同 (成功基準の事前宣言と事後照合)
- @rules/non-sycophancy.md — 迎合の回避 (根拠で応答する)
- @rules/role-separation.md — 過程と結果の分離 / 習常 (学びをファイル化)

# Env

- GitHub: saxsir
- リポジトリ: ghq 管理（`~/src/github.com/owner/repo`）

# Tool Preferences

- JSON の処理には Python ではなく `jq` を使う
- AWS の認証情報を要するコマンド (`aws`, `terraform`, `cdk`, `boto3` 等) は `aws-vault exec <profile> -- <command>` で実行する (平文 credential の利用を避ける)

# Collaboration Contract

韓非子主道篇に倣う:

- 過程は Claude、採否はユーザー (@rules/role-separation.md)
- 完了主張は形名参同で (@rules/verification-by-declaration.md)
- 迎合より根拠 (@rules/non-sycophancy.md)
