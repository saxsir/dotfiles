# Fix GitHub Issue Command
GitHub Issue #$ARGUMENTS を分析して修正してください。

## Issue情報（事前取得）

```bash
# Issue詳細情報
gh issue view $ARGUMENTS --json number,title,body,author,state,labels,comments

# 現在のブランチとgit状態
git status --short --branch

# 最近のコミット履歴
git log --oneline -10
```

## 修正手順

### 1. Issue内容の理解
- Issue本文とコメントから問題の本質を把握
- 再現手順や期待される動作を確認
- 関連するラベルやマイルストーンを確認

### 2. ブランチ作成
適切な命名規則でブランチを作成：
```bash
git checkout -b <type>/<issue-number>/<short-description>
```

例：
- `fix/123/update-readme`
- `feat/456/add-dark-mode`
- `refactor/789/simplify-auth`

### 3. 実装
- 問題を解決するコード変更を実施
- 必要に応じてテストを追加・更新
- リント・型チェックを実行

### 4. 検証
- 変更が意図通りに動作することを確認
- 既存機能に影響がないことを確認
- テストがすべてパスすることを確認

### 5. コミット
明確なコミットメッセージで変更を記録：
```bash
git commit -m "fix: <what was fixed>

- <details>
- <details>

Fixes #$ARGUMENTS"
```

## 重要な注意事項

- GitHub CLI (`gh`) を使用してIssue情報を取得
- 小さく段階的に変更を進める
- 各ステップでgit statusを確認
- コミット前に必ずテストとリントを実行
