# GitHub ワークフロー

GitHub Issue / PR を扱う際のルール。ローカル git 操作は Git ブランチワークフローを、文章の書き方は GitHub に書く文章を参照。

## Umbrella Issue

複数の関連タスクをまとめる issue。基本はチェックリストで管理する。

- タイトル prefix `[Umbrella]` を付ける（例: `[Umbrella] zsh 起動高速化`）
- 子 issue への切り出しはユーザーの判断に委ねる。ユーザーから指示があった場合のみ行う:
  `gh issue create` → 内部 ID 取得 (`gh api repos/:owner/:repo/issues/<n> --jq .id`) → `gh api -X POST .../sub_issues -F sub_issue_id=<id>` で link → umbrella のチェックリスト行を `#<child>` に置き換え

## Issue から作業を始める

1. `gh issue view <number>` で Issue を読む
2. ブランチを切って実装する
3. 完了後に draft PR を作成

## PR 作成

- 必ず draft で作る: `gh pr create --draft`
- 作成後はブラウザで開く: `gh pr view --web`
- タイトルは Issue があればそのタイトルに合わせる (簡潔さのため調整可)

### 本文

`.github/` 配下に PR テンプレートがあればそれを埋める。なければ:

```markdown
## What
何をしたか (1〜3 行)

## Why
なぜこの変更が必要だったか

Closes #<Issue 番号>
```

- `Closes #XXX` で自動クローズ。しない場合は `Relates to #XXX` か `gh pr edit <n> --add-issue <n>`

## レビューコメントへの応答

1. unresolved コメントを取得: `gh api repos/{owner}/{repo}/pulls/<number>/comments`
2. 修正前に**応答計画をユーザーに提示し承認を得る**
3. コミットはコメント単位またはファイル単位で分ける
4. Push 後、ユーザーの確認を得てからレビュースレッドに返信

## 他 Issue / PR の参照

description・コメント本文で他の Issue / PR を参照するときは完全な URL を使う（例: `https://github.com/owner/repo/pull/1234`）。同一リポジトリ内の `#番号`（`Closes #XXX` 等の自動クローズ含む）はそのままで良い（理由: GitHub の自動リンクは同一リポジトリ内の `#番号` しか確実に解決せず、別リポジトリの省略形 `owner/repo#番号` はリンクされないことがある）。

## 追加コミット後の description 確認

既存 PR にコミットを追加した後（レビュー対応・仕様変更・追加実装など）は、必ず以下を確認する:

1. **PR description** の What / Why が最新の変更内容を反映しているか
2. **紐づく Issue** の description（再現手順・仕様・チェックリスト等）が古くなっていないか

変更が必要な場合は「PR description の更新」セクションの手順に従って更新する。

## PR description の更新

既存 PR の description を書き換える際は全文再生成して上書きしない。必ず `gh pr view <n> --json body --jq .body` で現在の body を取得してベースにし、変更箇所だけ編集した新 body の差分をユーザーに提示してから承認後に `gh pr edit` を実行する。
