# GitHub ワークフロー

GitHub Issue / PR を扱う際のルール。ローカル git 操作は Git ブランチワークフローを参照。

## Issue から作業を始める

1. `gh issue view <number>` で Issue を読む
2. ブランチを切って実装する (命名規則は `git-branch-workflow.md`)
3. 完了後に draft PR を作成

関連 skill: `/fix-issue`

## PR 作成

- 必ず draft で作る: `gh pr create --draft`
- 作成後はブラウザで開く: `gh pr view --web`
- Ready にするのはユーザーのみ。Claude は `gh pr ready` を**絶対に実行しない**

関連 skill: `/commit-and-pr`

### タイトル

Issue があればそのタイトルに合わせる (簡潔さのため調整可)。

### 本文

`.github/` 配下に PR テンプレート (`pull_request_template.md`, `PULL_REQUEST_TEMPLATE.md` 等) があれば、それを埋める形で書く。

なければ以下の構造で書く:

```markdown
## What
何をしたか (1〜3 行)

## Why
なぜこの変更が必要だったか

Closes #<Issue 番号>
```

- `Closes #XXX` で Issue を自動クローズ
- 自動クローズせず関連付けだけしたい場合は `Relates to #XXX`

## PR と Issue のリンク

- 本文の `Closes #XXX` で自動リンク
- 自動クローズしないリンクは `gh pr edit <pr-number> --add-issue <issue-number>`

## レビューコメントへの応答

1. unresolved コメントを取得: `gh api repos/{owner}/{repo}/pulls/<number>/comments`
2. 修正に着手する前に**応答計画をユーザーに提示**
3. コミットはコメント単位またはファイル単位で分ける
4. Push 後、ユーザーの確認を得てからレビュースレッドに返信

## 禁止事項

- Issue を読まずに実装を始める
- `gh pr ready` を実行する (ユーザーのみが行う)
- ユーザーの承認なくレビューコメントに対応する
