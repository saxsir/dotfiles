# Commit, Push, and Create PR Command

変更をコミット→プッシュ→draft PR作成まで一気に実行します。

## 現在の状態（事前取得）

```bash
# Git状態
git status --short --branch

# 差分（staged + unstaged）
git diff HEAD

# 変更ファイルの統計
git diff --stat HEAD

# 最近のコミット履歴（スタイル参考用）
git log --oneline -5

# 現在のブランチ
git rev-parse --abbrev-ref HEAD
```

## 実行手順

### 1. 変更内容の確認と分析
- ステージングされている変更とされていない変更を確認
- 変更の意図と影響範囲を把握
- コミットメッセージの内容を考える

### 2. 必要なファイルをステージング
関連する変更ファイルを `git add` でステージング

### 3. コミットメッセージの作成
最近のコミット履歴のスタイルに合わせて、明確なコミットメッセージを作成：
```
<type>: <subject>

<body>
```

### 4. コミット実行
```bash
git commit -m "コミットメッセージ"
```

### 5. プッシュ
```bash
git push -u origin <branch-name>
```

### 6. PR説明文の生成
ベースブランチ（main/master）との差分を確認：
```bash
git diff origin/main...HEAD || git diff origin/master...HEAD
git log origin/main..HEAD --oneline || git log origin/master..HEAD --oneline
```

CLAUDE.mdの形式に従ってPR説明文を生成：
```markdown
## What
{{ なにを変えたか？の事実を記載する }}

## Why
{{ なぜこの変更が必要だったのか？を記載する }}
```

### 7. PR文言の確認
⚠️ **重要**: PR作成前に、生成したタイトルと説明文をユーザーに提示して確認・修正してもらう

### 8. Draft PR作成
ユーザーが承認したら、draft PRを作成：
```bash
gh pr create --draft --title "タイトル" --body "説明文"
```

## 注意事項

- コミット前にgit statusで変更を必ず確認
- PRタイトルと説明文は必ずユーザー確認を経てから作成
- Draft PRとして作成（Ready for reviewはユーザーが手動で切り替え）
- 秘密情報（.env、credentials.jsonなど）をコミットしないよう注意
