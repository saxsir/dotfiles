# GitHub ワークフロー

GitHub Issue / PR を扱うルール。git 操作は [[git-branch-workflow]]、文章規約は [[github-writing]]。

## Issue から作業を始める

`gh issue view <number>` → ブランチ → 実装 → draft PR。

## PR 作成

- 必ず draft: `gh pr create --draft`
- 作成後ブラウザで開く: `gh pr view --web`
- タイトルは Issue タイトルに合わせる (調整可)
- `.github/` にテンプレあればそれを埋める。なければ:

```markdown
## What
何をしたか (1〜3 行)

## Why
なぜ必要か

Closes #<n>
```

`Closes #XXX` で自動クローズ (しないなら `Relates to #XXX` か `gh pr edit <n> --add-issue <n>`)。

## レビューコメント応答

1. `gh api repos/{owner}/{repo}/pulls/<n>/comments` で unresolved 取得
2. **応答計画をユーザーに提示し承認を得る**
3. コミットはコメント単位 / ファイル単位で分割
4. Push 後、ユーザーの確認を得てからレビュースレッドに返信

## 他 Issue / PR の参照

description / コメント本文で参照は **完全な URL** を使う (`https://github.com/owner/repo/pull/1234`)。同一リポ内の `#番号` (`Closes #XXX` 等) はそのままで良い (GitHub の自動リンクは同一リポ内の `#番号` しか確実に解決しないため)。

## 追加コミット後

既存 PR にコミットを追加したら、PR description の What/Why が最新変更を反映しているか、紐づく Issue description が古くなっていないかを確認・更新する。

## PR description の更新

全文再生成して上書きしない。必ず `gh pr view <n> --json body --jq .body` で現在の body を取得 → 変更箇所だけ編集 → 差分をユーザーに提示 → 承認後 `gh pr edit`。

## Umbrella Issue

タイトル prefix `[Umbrella]`、チェックリストで管理。子 issue 切り出しはユーザーの明示指示があるときのみ。
