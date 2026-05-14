---
name: review-assigned-pr
description: >
  自分にアサインされた GitHub PR の中からレビュー対象を選んで /review に渡すスキル。
  「アサインされたPRをレビューしたい」「レビュー待ちのPRを見せて」「assigned PR を選ばせて」
  と言われたとき、または明示的に /review-assigned-pr を呼ばれたときに使う。gh CLI が必要。
model: opus
---

# review-assigned-pr

自分にアサインされた open PR を一覧表示し、選択した PR を組み込みの `/review` に渡すスキル。

## 前提確認

以下を実行し、gh が認証済みであることを確認する:

```bash
gh auth status
```

失敗（exit code 非ゼロ）の場合は「`gh auth login` で認証してください」と伝えて停止する。

## PR 一覧の取得

```bash
gh search prs \
  --assignee @me \
  --state open \
  --limit 10 \
  --sort updated \
  --order desc \
  --json number,title,url,repository,updatedAt,author,isDraft
```

取得した JSON を jq で処理し、以下のフォーマットで番号付きリストを表示する:

```
 1. [DRAFT] owner/repo#1234  PR タイトル (@author, 2d ago)
    https://github.com/owner/repo/pull/1234
 2. owner/repo#238  別の PR タイトル (@author, 5h ago)
    https://github.com/owner/repo/pull/238
```

- `isDraft: true` の場合のみ `[DRAFT]` プレフィックスを付ける
- 相対日付は `date -d` (GNU coreutils) で算出する
- `repository` フィールドから `nameWithOwner` を取得して `owner/repo` 形式にする

結果が 0 件の場合は「アサインされた open PR はありません」と伝えて終了する。

## 入力受付

リスト表示後、以下のプロンプトを出してユーザー入力を待つ:

```
番号 (1-N)、PR URL、または owner/repo#番号 で選択してください:
```

入力の解釈:
- **数字のみ** → 上記リストの該当 PR の URL を採用
- **`owner/repo#N`** → その PR を採用（リスト外でも可）
- **`https://github.com/...`** → そのまま採用（リスト外でも可）
- 上記いずれにも当てはまらない場合は「認識できない入力です。」と伝えて再度入力を促す

## /review への委譲

選択が確定したら、1 行で宣言してから Skill ツールで `/review` を起動する:

```
<owner/repo#N または URL> をレビューします
```

Skill ツールを使い `review` スキルを PR の URL を引数として呼び出す。

## 注意事項

- `gh pr checkout` によるローカル取得はこのスキルでは行わない（`/review` 側の責務）
- レビューコメントの GitHub への投稿は `post-pr-review-comments` スキルの責務
