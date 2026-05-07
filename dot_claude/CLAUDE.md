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

# Tool Preferences

- JSON の処理には Python ではなく `jq` を使う
- AWS の認証情報を要するコマンド (`aws`, `terraform`, `cdk`, `boto3` 等) は `aws-vault exec <profile> -- <command>` で実行する (平文 credential の利用を避ける)
- サンドボックス有効環境で `git push` が osxkeychain dialog を出すときは、一時 git config で credential helper の multi-value を **空 `helper = ` でリセット** してから `gh auth git-credential` を載せる:
  ```bash
  printf '%s\n' '[credential]' $'\thelper = ' $'\thelper = !gh auth git-credential' > "$TMPDIR/git-https-only.cfg"
  GIT_CONFIG_GLOBAL="$TMPDIR/git-https-only.cfg" git push "https://github.com/owner/repo.git" <branch>
  ```
  理由: 空の `helper = ` で system 側 `credential.helper=osxkeychain` の継承を切るため、毎回 dialog が出る挙動を抑止できる
