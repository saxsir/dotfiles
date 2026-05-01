# GitHub ワークフロー

GitHub Issue / PR を扱う際のルール。ローカル git 操作は Git ブランチワークフローを参照。

## Issue から作業を始める

1. `gh issue view <number>` で Issue を読む
2. ブランチを切って実装する
3. 完了後に draft PR を作成

## PR 作成

- 必ず draft で作る: `gh pr create --draft`
- 作成後はブラウザで開く: `gh pr view --web`
- Ready にするのはユーザーのみ。Claude は `gh pr ready` を**絶対に実行しない**
- タイトルは Issue があればそのタイトルに合わせる (簡潔さのため調整可)

### 本文

`.github/` 配下に PR テンプレート (`pull_request_template.md` 等) があれば、それを埋める。なければ:

```markdown
## What
何をしたか (1〜3 行)

## Why
なぜこの変更が必要だったか

Closes #<Issue 番号>
```

- `Closes #XXX` で Issue を自動クローズ
- 自動クローズしないリンクは `Relates to #XXX`、または `gh pr edit <pr-number> --add-issue <issue-number>`

## レビューコメントへの応答

1. unresolved コメントを取得: `gh api repos/{owner}/{repo}/pulls/<number>/comments`
2. 修正前に**応答計画をユーザーに提示し承認を得る**
3. コミットはコメント単位またはファイル単位で分ける
4. Push 後、ユーザーの確認を得てからレビュースレッドに返信
