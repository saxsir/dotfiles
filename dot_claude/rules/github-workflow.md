# GitHub ワークフロー

GitHub Issue / PR を扱う際のルール。ローカル git 操作は Git ブランチワークフローを参照。

## Umbrella Issue

複数の関連タスクをまとめる issue。粒度未確定の段階ではチェックリストで管理し、着手時に子 issue として切り出して GitHub の sub-issue で紐付ける。

### 作成

- タイトル prefix `[Umbrella]` を付ける（例: `[Umbrella] zsh 起動高速化`）
- 本文はチェックリスト。issue 化が決まっていない項目は plain text で書く

```markdown
## やること
- [ ] zprof で計測
- [ ] nvm の lazy load 化
- [ ] pyenv の lazy load 化
```

### 子 issue を切り出す（着手時）

```bash
# 1. 子 issue を作成
gh issue create --title "nvm の lazy load 化" --body "Relates to #<umbrella>"

# 2. 子 issue の内部 ID (database id) を取得 ※ issue 番号ではない
child_id=$(gh api repos/:owner/:repo/issues/<child-number> --jq .id)

# 3. umbrella に sub-issue として link
gh api -X POST repos/:owner/:repo/issues/<umbrella-number>/sub_issues \
  -F sub_issue_id="${child_id}"

# 4. umbrella のチェックリスト該当行を issue 参照に置き換え
#    `- [ ] nvm の lazy load 化` → `- [ ] #<child-number>`
gh issue edit <umbrella-number> --body "..."
```

- sub-issue として link すると GitHub UI で親子関係が表示され、子の close で親のチェックリストが自動更新される
- `:owner/:repo` は `gh` の current repo context が解決する（`-R owner/repo` で明示指定も可）

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
